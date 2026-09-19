local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local Privacy = {}
FIT.Compat.Privacy = Privacy

local PLAYER_TOKEN = "<PLAYER>"

local function escapePattern(text)
    return (text:gsub("([^%w])", "%%%1"))
end

local function addAlias(list, seen, value)
    if type(value) ~= "string" or value == "" then
        return
    end

    if seen[value] then
        return
    end

    seen[value] = true
    list[#list + 1] = value

    local short = value:match("^([^%-]+)")
    if short and short ~= value and not seen[short] then
        seen[short] = true
        list[#list + 1] = short
    end
end

function Privacy:GetPlayerAliases()
    local aliases, seen = {}, {}
    local API = FIT.Compat.API

    if not API then
        return aliases
    end

    local unitName = API:CallGlobal("UnitName", "player")
    addAlias(aliases, seen, unitName)

    local fullName = API:CallGlobal("GetUnitName", "player", true)
    addAlias(aliases, seen, fullName)

    return aliases
end

function Privacy:SanitizeText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local sanitized = text

    for _, alias in ipairs(self:GetPlayerAliases()) do
        sanitized = sanitized:gsub(escapePattern(alias), PLAYER_TOKEN)
    end

    return sanitized
end

function Privacy:SanitizeSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return snapshot
    end

    for _, field in ipairs({
        "title",
        "description",
        "objectives",
        "progress",
        "completion",
        "zone",
        "category",
    }) do
        if snapshot[field] ~= nil then
            snapshot[field] = self:SanitizeText(snapshot[field])
        end
    end

    return snapshot
end
