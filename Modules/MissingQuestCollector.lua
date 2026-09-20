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

local function sourceTextChanged(snapshot, translated)
    if type(translated) ~= "table"
        or type(translated._sourceHashes) ~= "table"
        or not FIT.RecordFormat
        or not FIT.RecordFormat.FingerprintField then
        return false
    end

    local observed = FIT.RecordFormat:BuildContent(snapshot)

    for field, value in pairs(observed) do
        local expected = translated._sourceHashes[field]
        if expected then
            local actual = FIT.RecordFormat:FingerprintField(field, value)
            if actual ~= expected then
                return true
            end
        end
    end

    return false
end

local function chooseBucket(snapshot, flavor, translated, source)
    if not translated then
        return "missing", "translation_missing"
    end

    if flavor == "forever" and source == "classic" then
        return "verifyClassic", "classic_translation_needs_forever_verification"
    end

    if sourceTextChanged(snapshot, translated) then
        return "modified", "source_text_changed"
    end

    return nil, nil
end

function Collector:Observe(snapshot)
    if type(snapshot) ~= "table" or type(snapshot.id) ~= "number" or snapshot.id <= 0 then
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

    local bucketName, reason = chooseBucket(snapshot, flavor, translated, source)

    local function clearOtherBuckets(keep)
        for _, name in ipairs({ "missing", "verifyClassic", "modified" }) do
            if name ~= keep and type(db[name]) == "table" then
                db[name][snapshot.id] = nil
            end
        end
    end

    if not bucketName then
        clearOtherBuckets(nil)
        return
    end

    clearOtherBuckets(bucketName)

    local bucket = db[bucketName]
    if type(bucket) ~= "table" then
        return
    end

    local current = bucket[snapshot.id]
    local nextRecord = FIT.RecordFormat:BuildRecord(snapshot, reason, source, current)

    if current and current.contentHash == nextRecord.contentHash then
        current.client = nextRecord.client
        current.context = nextRecord.context
        current.addonVersion = FIT.version
        return
    end

    if not current and countEntries(bucket) >= MAX_QUESTS_PER_BUCKET then
        db.dropped = (db.dropped or 0) + 1
        return
    end

    if current then
        nextRecord.revision = (tonumber(current.revision) or 1) + 1
    end

    bucket[snapshot.id] = nextRecord
end


if FIT.Compat.Quest and FIT.Compat.Quest.RegisterListener then
    FIT.Compat.Quest:RegisterListener(function(event, snapshot)
        if event ~= "QUEST_FINISHED" then
            Collector:Observe(snapshot)
        end
    end)
end
