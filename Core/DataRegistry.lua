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

    self[layer].quests[questID] = record
end

function Data:ResolveQuest(questID, flavor)
    if not isValidQuestID(questID) then
        return nil, "invalid_id"
    end

    local base = self.classic.quests[questID]

    if flavor ~= "forever" then
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
            merged[key] = deepCopy(value)
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
