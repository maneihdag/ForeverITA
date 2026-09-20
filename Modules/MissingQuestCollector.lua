local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local Collector = {}
FIT.MissingQuestCollector = Collector

local MAX_QUESTS_PER_BUCKET = 2000

local function countEntries(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

local function getDB()
    if FIT.Compat.Storage and FIT.Compat.Storage.GetCollectorDB then
        return FIT.Compat.Storage:GetCollectorDB()
    end
    return nil
end

local CONTENT_FIELDS = {
    "title",
    "description",
    "objectives",
    "progress",
    "completion",
}

local BUCKETS = {
    "missing",
    "incomplete",
    "modified",
    "verifyClassic",
}

local function hasText(value)
    return type(value) == "string" and value:match("%S") ~= nil
end

local function copySnapshot(snapshot)
    local copy = {}
    for key, value in pairs(snapshot or {}) do
        copy[key] = value
    end
    return copy
end

local function getPriorRecord(db, questID)
    for _, bucketName in ipairs(BUCKETS) do
        local bucket = db[bucketName]
        if type(bucket) == "table" and type(bucket[questID]) == "table" then
            return bucket[questID], bucketName
        end
    end
    return nil, nil
end

local function mergePriorEvidence(snapshot, previous)
    local merged = copySnapshot(snapshot)

    if type(previous) == "table" and type(previous.content) == "table" then
        for _, field in ipairs(CONTENT_FIELDS) do
            if merged[field] == nil and previous.content[field] ~= nil then
                merged[field] = previous.content[field]
            end
        end
    end

    return merged
end

local function buildSelectedSnapshot(snapshot, selectedContent)
    local selected = copySnapshot(snapshot)

    for _, field in ipairs(CONTENT_FIELDS) do
        selected[field] = nil
    end

    for field, value in pairs(selectedContent or {}) do
        selected[field] = value
    end

    return selected
end

local function observedContent(snapshot)
    if not FIT.RecordFormat or not FIT.RecordFormat.BuildContent then
        return {}
    end

    local raw = FIT.RecordFormat:BuildContent(snapshot)
    local filtered = {}

    for field, value in pairs(raw) do
        if hasText(value) then
            filtered[field] = value
        end
    end

    return filtered
end

local function missingTranslationFields(snapshot, translated)
    local missing = {}

    if type(translated) ~= "table" then
        return missing
    end

    for field, value in pairs(observedContent(snapshot)) do
        if not hasText(translated[field]) then
            missing[field] = value
        end
    end

    return missing
end

local function changedSourceFields(snapshot, translated)
    local changed = {}

    if type(translated) ~= "table"
        or type(translated._sourceHashes) ~= "table"
        or not FIT.RecordFormat
        or not FIT.RecordFormat.FingerprintField then
        return changed
    end

    local dynamicFields = type(translated._dynamicFields) == "table"
        and translated._dynamicFields
        or {}

    for field, value in pairs(observedContent(snapshot)) do
        if dynamicFields[field] == nil then
            local expected = translated._sourceHashes[field]
            if expected then
                local actual = FIT.RecordFormat:FingerprintField(field, value)
                if actual ~= expected then
                    changed[field] = value
                end
            end
        end
    end

    return changed
end

local function hasEntries(tbl)
    return type(tbl) == "table" and next(tbl) ~= nil
end

local function chooseBucket(snapshot, flavor, translated, source)
    local content = observedContent(snapshot)

    if not translated then
        return "missing", "translation_missing", content
    end

    local modified = changedSourceFields(snapshot, translated)
    if hasEntries(modified) then
        return "modified", "source_text_changed", modified
    end

    local incomplete = missingTranslationFields(snapshot, translated)
    if hasEntries(incomplete) then
        return "incomplete", "translation_field_missing", incomplete
    end

    if flavor == "forever" and source == "classic" then
        return "verifyClassic", "classic_translation_needs_forever_verification", content
    end

    return nil, nil, nil
end

function Collector:Observe(snapshot)
    if type(snapshot) ~= "table"
        or type(snapshot.id) ~= "number"
        or snapshot.id <= 0
        or math.floor(snapshot.id) ~= snapshot.id then
        return
    end

    if not FIT.RecordFormat then
        return
    end

    local db = getDB()
    if not db then
        return
    end

    local flavor = "unknown"
    if FIT.Compat.Client and FIT.Compat.Client.GetDataFlavor then
        flavor = FIT.Compat.Client:GetDataFlavor()
    end

    if flavor ~= "classic" and flavor ~= "forever" then
        if FIT.Compat.Storage and FIT.Compat.Storage.RecordDiagnostic then
            FIT.Compat.Storage:RecordDiagnostic("collector_unsupported_flavor")
        end
        return
    end

    local translated, source = nil, "missing"
    if FIT.Data and FIT.Data.ResolveQuest then
        translated, source = FIT.Data:ResolveQuest(snapshot.id, flavor)
    end

    local priorRecord = getPriorRecord(db, snapshot.id)
    local classificationSnapshot = mergePriorEvidence(snapshot, priorRecord)
    local bucketName, reason, selectedContent =
        chooseBucket(classificationSnapshot, flavor, translated, source)

    local function clearOtherBuckets(keep)
        for _, name in ipairs(BUCKETS) do
            if name ~= keep and type(db[name]) == "table" then
                db[name][snapshot.id] = nil
            end
        end
    end

    if not bucketName then
        clearOtherBuckets(nil)
        return
    end

    local bucket = db[bucketName]
    if type(bucket) ~= "table" then
        return
    end

    local selectedSnapshot = buildSelectedSnapshot(classificationSnapshot, selectedContent)
    local current = bucket[snapshot.id]

    local priorForBuild = nil
    if priorRecord then
        priorForBuild = {
            content = {},
            context = priorRecord.context,
            client = priorRecord.client,
            revision = priorRecord.revision,
        }
    end

    local nextRecord =
        FIT.RecordFormat:BuildRecord(selectedSnapshot, reason, source, priorForBuild)

    if current and current.contentHash == nextRecord.contentHash then
        current.client = nextRecord.client
        current.context = nextRecord.context
        current.addonVersion = FIT.version
        current.reason = reason
        current.sourceAtCapture = source
        clearOtherBuckets(bucketName)
        return
    end

    if not current and countEntries(bucket) >= MAX_QUESTS_PER_BUCKET then
        db.dropped = (db.dropped or 0) + 1
        return
    end

    if priorRecord then
        local previousRevision = tonumber(priorRecord.revision) or 1
        if priorRecord.contentHash ~= nextRecord.contentHash then
            nextRecord.revision = previousRevision + 1
        else
            nextRecord.revision = previousRevision
        end
    end

    clearOtherBuckets(bucketName)
    bucket[snapshot.id] = nextRecord
end


if FIT.Compat.Quest and FIT.Compat.Quest.RegisterListener then
    FIT.Compat.Quest:RegisterListener(function(event, snapshot)
        if event ~= "QUEST_FINISHED" then
            Collector:Observe(snapshot)
        end
    end)
end
