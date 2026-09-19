local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local RecordFormat = {
    schema = 1,
}

FIT.RecordFormat = RecordFormat

local HASH_MOD = 2147483647
local HASH_MULTIPLIER = 131

local CONTENT_FIELDS = {
    "title",
    "description",
    "objectives",
    "progress",
    "completion",
    "zone",
    "mapID",
}

local function appendPart(parts, name, value)
    if value == nil then
        return
    end

    value = tostring(value)
    parts[#parts + 1] = name
    parts[#parts + 1] = ":"
    parts[#parts + 1] = tostring(#value)
    parts[#parts + 1] = ":"
    parts[#parts + 1] = value
    parts[#parts + 1] = "|"
end

function RecordFormat:BuildContent(snapshot)
    local content = {}

    for _, field in ipairs(CONTENT_FIELDS) do
        if snapshot[field] ~= nil then
            content[field] = snapshot[field]
        end
    end

    return content
end

function RecordFormat:Fingerprint(questID, content)
    local parts = {
        "ForeverITAQuestRecord|schema:",
        tostring(self.schema),
        "|id:",
        tostring(questID),
        "|",
    }

    for _, field in ipairs(CONTENT_FIELDS) do
        appendPart(parts, field, content[field])
    end

    local canonical = table.concat(parts)
    local hash = 7

    for i = 1, #canonical do
        hash = (hash * HASH_MULTIPLIER + string.byte(canonical, i)) % HASH_MOD
    end

    return "q" .. tostring(self.schema) .. "-" .. tostring(hash)
end

function RecordFormat:BuildRecord(snapshot, reason, sourceAtCapture)
    local content = self:BuildContent(snapshot)

    return {
        schema = self.schema,
        type = "quest",
        id = snapshot.id,
        reason = reason,
        sourceAtCapture = sourceAtCapture,
        content = content,
        contentHash = self:Fingerprint(snapshot.id, content),
        addonVersion = FIT.version,
        client = snapshot.build,
        revision = 1,
    }
end
