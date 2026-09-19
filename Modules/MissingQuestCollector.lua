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
local TEXT_FIELDS = {
    "title",
    "description",
    "objectives",
    "progress",
    "completion",
    "npcGUID",
    "npcName",
}

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

local function mergeSnapshot(record, snapshot)
    record.events = record.events or {}
    record.events[snapshot.event or "UNKNOWN"] = (record.events[snapshot.event or "UNKNOWN"] or 0) + 1

    for _, field in ipairs(TEXT_FIELDS) do
        if snapshot[field] ~= nil then
            record[field] = snapshot[field]
        end
    end

    record.lastBuild = snapshot.build or record.lastBuild
end

function Collector:Observe(snapshot)
    if type(snapshot) ~= "table" or type(snapshot.id) ~= "number" or snapshot.id <= 0 then
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

    local bucketName
    local reason

    if not translated then
        bucketName = "missing"
        reason = "translation_missing"
    elseif flavor == "forever" and source == "classic" then
        bucketName = "verifyClassic"
        reason = "classic_translation_needs_forever_verification"
    else
        return
    end

    local bucket = db[bucketName]
    local record = bucket[snapshot.id]

    if not record then
        if countEntries(bucket) >= MAX_QUESTS_PER_BUCKET then
            db.dropped = (db.dropped or 0) + 1
            return
        end

        record = {
            id = snapshot.id,
            reason = reason,
            sourceAtCapture = source,
        }

        bucket[snapshot.id] = record
    end

    mergeSnapshot(record, snapshot)
end

function Collector:GetCounts()
    local db = getDB()
    if not db then
        return 0, 0, 0
    end

    return countEntries(db.missing), countEntries(db.verifyClassic), db.dropped or 0
end

function Collector:PrintStatus()
    local missing, verifyClassic, dropped = self:GetCounts()

    FIT:Print(
        string.format(
            "Collector: missing=%d verifyClassic=%d dropped=%d",
            missing,
            verifyClassic,
            dropped
        )
    )

    local flavor = "unknown"
    if FIT.Compat.Client and FIT.Compat.Client.GetDataFlavor then
        flavor = FIT.Compat.Client:GetDataFlavor()
    end

    FIT:Print("Ambiente dati: " .. flavor)
end
