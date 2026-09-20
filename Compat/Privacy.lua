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

local function isNameByte(byte)
    if not byte then
        return false
    end

    return (byte >= 48 and byte <= 57)
        or (byte >= 65 and byte <= 90)
        or (byte >= 97 and byte <= 122)
        or byte == 95
        or byte >= 128
end

local function replaceAliasToken(text, alias)
    local cursor = 1

    while true do
        local first, last = text:find(alias, cursor, true)
        if not first then
            break
        end

        local previousByte = first > 1 and text:byte(first - 1) or nil
        local nextByte = last < #text and text:byte(last + 1) or nil

        if not isNameByte(previousByte) and not isNameByte(nextByte) then
            text =
                text:sub(1, first - 1)
                .. PLAYER_TOKEN
                .. text:sub(last + 1)
            cursor = first + #PLAYER_TOKEN
        else
            cursor = last + 1
        end
    end

    return text
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

    local fullName = API:CallGlobal("GetUnitName", "player", true)
    addAlias(aliases, seen, fullName)

    local unitName = API:CallGlobal("UnitName", "player")
    addAlias(aliases, seen, unitName)

    return aliases
end

function Privacy:SanitizeText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local sanitized = text

    for _, alias in ipairs(self:GetPlayerAliases()) do
        sanitized = replaceAliasToken(sanitized, alias)
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


function Privacy:PersonalizeText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local API = FIT.Compat.API
    if not API then
        return text
    end

    local playerName = API:CallGlobal("UnitName", "player")
    if type(playerName) ~= "string" or playerName == "" then
        return text
    end

    return (text:gsub("<PLAYER>", function()
        return playerName
    end))
end
