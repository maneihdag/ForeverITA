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

local SCHEMA = 1
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

local function now()
    if type(GetServerTime) == "function" then
        local ok, value = pcall(GetServerTime)
        if ok and type(value) == "number" then
            return value
        end
    end

    if type(time) == "function" then
        local ok, value = pcall(time)
        if ok and type(value) == "number" then
            return value
        end
    end

    return 0
end

local function countEntries(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

local function ensureDB()
    local db = _G.ForeverITA_CollectorDB

    if type(db) ~= "table" or db.schema ~= SCHEMA then
        db = {
            schema = SCHEMA,
            missing = {},
            verifyClassic = {},
            dropped = 0,
        }
    end

    db.missing = type(db.missing) == "table" and db.missing or {}
    db.verifyClassic = type(db.verifyClassic) == "table" and db.verifyClassic or {}
    db.dropped = tonumber(db.dropped) or 0

    if FIT.Environment and FIT.Environment.GetBuildSnapshot then
        db.lastBuild = FIT.Environment:GetBuildSnapshot()
    end

    _G.ForeverITA_CollectorDB = db
    return db
end

local function mergeSnapshot(record, snapshot)
    record.events = record.events or {}
    record.events[snapshot.event or "UNKNOWN"] = (record.events[snapshot.event or "UNKNOWN"] or 0) + 1

    for _, field in ipairs(TEXT_FIELDS) do
        if snapshot[field] ~= nil then
            record[field] = snapshot[field]
        end
    end

    record.lastSeen = now()
    record.lastBuild = snapshot.build or record.lastBuild
end

function Collector:Observe(snapshot)
    if type(snapshot) ~= "table" or type(snapshot.id) ~= "number" or snapshot.id <= 0 then
        return
    end

    local flavor = FIT.Environment and FIT.Environment:GetDataFlavor() or "unknown"
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
        -- Una traduzione Classic non viene considerata automaticamente valida su Forever.
        -- Conserviamo il testo osservato per un confronto successivo.
        bucketName = "verifyClassic"
        reason = "classic_translation_needs_forever_verification"
    else
        return
    end

    local db = ensureDB()
    local bucket = db[bucketName]

    local record = bucket[snapshot.id]
    if not record then
        if countEntries(bucket) >= MAX_QUESTS_PER_BUCKET then
            db.dropped = db.dropped + 1
            return
        end

        record = {
            id = snapshot.id,
            firstSeen = now(),
            reason = reason,
            sourceAtCapture = source,
        }
        bucket[snapshot.id] = record
    end

    mergeSnapshot(record, snapshot)
end

function Collector:GetCounts()
    local db = ensureDB()
    return countEntries(db.missing), countEntries(db.verifyClassic), db.dropped
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

    if FIT.Environment then
        FIT:Print("Flavor: " .. tostring(FIT.Environment:GetDataFlavor()))
    end
end
