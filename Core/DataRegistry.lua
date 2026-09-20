local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local Data = {
    classic = { quests = {} },
    forever = { quests = {} },
}

FIT.Data = Data

local function deepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] then
        return seen[value]
    end

    local copy = {}
    seen[value] = copy

    for key, child in pairs(value) do
        copy[deepCopy(key, seen)] = deepCopy(child, seen)
    end

    return copy
end

local function isValidQuestID(questID)
    return type(questID) == "number"
        and questID > 0
        and math.floor(questID) == questID
end

local function mergeMap(base, override)
    local merged = {}

    if type(base) == "table" then
        for key, value in pairs(base) do
            merged[key] = deepCopy(value)
        end
    end

    if type(override) == "table" then
        for key, value in pairs(override) do
            merged[key] = deepCopy(value)
        end
    end

    return merged
end

function Data:RegisterQuest(layer, questID, record)
    if layer ~= "classic" and layer ~= "forever" then
        error("ForeverITA: layer dati non valido: " .. tostring(layer))
    end

    if not isValidQuestID(questID) then
        error("ForeverITA: QuestID non valido: " .. tostring(questID))
    end

    if type(record) ~= "table" then
        error("ForeverITA: record quest non valido per " .. tostring(questID))
    end

    if self[layer].quests[questID] ~= nil then
        error(
            "ForeverITA: QuestID duplicato nel layer "
                .. tostring(layer)
                .. ": "
                .. tostring(questID)
        )
    end

    self[layer].quests[questID] = record
end

function Data:ForEachQuest(layer, callback)
    if layer ~= "classic" and layer ~= "forever" then
        return false, "invalid_layer"
    end

    if type(callback) ~= "function" then
        return false, "invalid_callback"
    end

    local ids = {}
    for questID in pairs(self[layer].quests) do
        ids[#ids + 1] = questID
    end
    table.sort(ids)

    for _, questID in ipairs(ids) do
        callback(questID, deepCopy(self[layer].quests[questID]))
    end

    return true
end

function Data:ResolveQuest(questID, flavor)
    if not isValidQuestID(questID) then
        return nil, "invalid_id"
    end

    if flavor ~= "classic" and flavor ~= "forever" then
        return nil, "unsupported_flavor"
    end

    local base = self.classic.quests[questID]

    if flavor == "classic" then
        if base then
            return deepCopy(base), "classic"
        end
        return nil, "missing"
    end

    local override = self.forever.quests[questID]
    if not override then
        if base then
            return deepCopy(base), "classic"
        end
        return nil, "missing"
    end

    if override._mode == "remove" then
        return nil, "forever_removed"
    end

    if override._mode == "replace" or not base then
        local replaced = deepCopy(override)
        replaced._mode = nil
        return replaced, base and "forever_replace" or "forever"
    end

    local merged = deepCopy(base)
    for key, value in pairs(override) do
        if key ~= "_mode" then
            if key == "_sourceHashes" or key == "_dynamicFields" then
                merged[key] = mergeMap(base[key], value)
            else
                merged[key] = deepCopy(value)
            end
        end
    end

    local textFields = {
        "title",
        "description",
        "objectives",
        "progress",
        "completion",
    }

    for _, field in ipairs(textFields) do
        if override[field] ~= nil then
            if type(merged._sourceHashes) == "table"
                and (
                    type(override._sourceHashes) ~= "table"
                    or override._sourceHashes[field] == nil
                ) then
                merged._sourceHashes[field] = nil
            end

            if type(merged._dynamicFields) == "table"
                and (
                    type(override._dynamicFields) ~= "table"
                    or override._dynamicFields[field] == nil
                ) then
                merged._dynamicFields[field] = nil
            end
        end
    end

    return merged, "forever_override"
end

function Data:GetCounts()
    local classicCount, foreverCount = 0, 0

    for _ in pairs(self.classic.quests) do
        classicCount = classicCount + 1
    end

    for _ in pairs(self.forever.quests) do
        foreverCount = foreverCount + 1
    end

    return classicCount, foreverCount
end
