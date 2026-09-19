local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local RecordFormat = {
    schema = 2,
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
}

local CONTEXT_FIELDS = {
    "zone",
    "mapID",
    "category",
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

function RecordFormat:BuildContext(snapshot)
    local context = {}

    for _, field in ipairs(CONTEXT_FIELDS) do
        if snapshot[field] ~= nil then
            context[field] = snapshot[field]
        end
    end

    return context
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

local function mergeTables(base, patch)
    local merged = {}

    if type(base) == "table" then
        for key, value in pairs(base) do
            merged[key] = value
        end
    end

    if type(patch) == "table" then
        for key, value in pairs(patch) do
            merged[key] = value
        end
    end

    return merged
end

function RecordFormat:BuildRecord(snapshot, reason, sourceAtCapture, previous)
    local observedContent = self:BuildContent(snapshot)
    local observedContext = self:BuildContext(snapshot)

    local content = mergeTables(previous and previous.content, observedContent)
    local context = mergeTables(previous and previous.context, observedContext)

    return {
        schema = self.schema,
        type = "quest",
        id = snapshot.id,
        reason = reason,
        sourceAtCapture = sourceAtCapture,
        content = content,
        context = context,
        contentHash = self:Fingerprint(snapshot.id, content),
        addonVersion = FIT.version,
        client = snapshot.build or (previous and previous.client),
        revision = previous and (tonumber(previous.revision) or 1) or 1,
    }
end
