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

local function chooseBucket(snapshot, flavor, translated, source)
    if not translated then
        return "missing", "translation_missing"
    end

    if flavor == "forever" and source == "classic" then
        return "verifyClassic", "classic_translation_needs_forever_verification"
    end

    if type(translated) == "table" and translated._sourceHash and FIT.RecordFormat then
        local observedContent = FIT.RecordFormat:BuildContent(snapshot)
        local observedHash = FIT.RecordFormat:Fingerprint(snapshot.id, observedContent)

        if observedHash ~= translated._sourceHash then
            return "modified", "source_text_changed"
        end
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

    local translated, source = nil, "missing"
    if FIT.Data and FIT.Data.ResolveQuest then
        translated, source = FIT.Data:ResolveQuest(snapshot.id, flavor)
    end

    local bucketName, reason = chooseBucket(snapshot, flavor, translated, source)
    if not bucketName then
        return
    end

    local bucket = db[bucketName]
    if type(bucket) ~= "table" then
        return
    end

    local nextRecord = FIT.RecordFormat:BuildRecord(snapshot, reason, source)
    local current = bucket[snapshot.id]

    if current and current.contentHash == nextRecord.contentHash then
        current.client = nextRecord.client
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
