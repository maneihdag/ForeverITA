local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local Client = {}
FIT.Compat.Client = Client

local state = {}

function Client:Refresh()
    local version, build, buildDate, interfaceVersion

    if type(GetBuildInfo) == "function" then
        local ok, a, b, c, d = pcall(GetBuildInfo)
        if ok then
            version, build, buildDate, interfaceVersion = a, b, c, d
        end
    end

    state.version = version
    state.build = build
    state.buildDate = buildDate
    state.interface = tonumber(interfaceVersion)
    state.projectID = _G.WOW_PROJECT_ID

    local classicProjectID = _G.WOW_PROJECT_CLASSIC
    state.isClassicEra =
        (classicProjectID ~= nil and state.projectID == classicProjectID)
        or (
            type(version) == "string"
            and version:match("^1%.15%.") ~= nil
        )

    -- Riconoscimento temporaneo della beta Forever attuale.
    -- DA TESTARE SU FOREVER e da aggiornare se Blizzard cambia la linea versione.
    state.isForeverBeta =
        type(version) == "string"
        and version:match("^1%.60%.") ~= nil

    if state.isForeverBeta then
        state.isClassicEra = false
    end
end

function Client:GetState()
    if state.version == nil and state.interface == nil then
        self:Refresh()
    end
    return state
end

function Client:GetDataFlavor()
    local current = self:GetState()

    if current.isForeverBeta then
        return "forever"
    end

    if current.isClassicEra then
        return "classic"
    end

    return "unknown"
end

function Client:GetBuildSnapshot()
    local current = self:GetState()

    return {
        version = current.version,
        build = current.build,
        interface = current.interface,
        projectID = current.projectID,
        flavor = self:GetDataFlavor(),
    }
end

function Client:Describe()
    local current = self:GetState()

    return string.format(
        "Client=%s Build=%s Interface=%s Ambiente=%s",
        tostring(current.version),
        tostring(current.build),
        tostring(current.interface),
        self:GetDataFlavor()
    )
end

Client:Refresh()
