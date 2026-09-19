local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local Environment = {}
FIT.Environment = Environment

local state = {}

function Environment:Refresh()
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

    -- Verificato per la beta 1.60.1 / interface 16001.
    -- NON usare questo controllo fuori da questo file: il valore può cambiare al lancio.
    state.isForeverBeta =
        type(version) == "string"
        and version:match("^1%.60%.") ~= nil
        and state.interface == 16001

    state.isClassicEra = state.interface == 11509
end

function Environment:GetState()
    if state.interface == nil then
        self:Refresh()
    end
    return state
end

function Environment:IsForever()
    return self:GetState().isForeverBeta == true
end

function Environment:GetDataFlavor()
    local current = self:GetState()

    if current.isForeverBeta then
        return "forever"
    end

    if current.isClassicEra then
        return "classic"
    end

    return "unknown"
end

function Environment:GetBuildSnapshot()
    local current = self:GetState()
    return {
        version = current.version,
        build = current.build,
        interface = current.interface,
        projectID = current.projectID,
        flavor = self:GetDataFlavor(),
    }
end

function Environment:Describe()
    local current = self:GetState()

    return string.format(
        "Client=%s Build=%s Interface=%s DataFlavor=%s",
        tostring(current.version),
        tostring(current.build),
        tostring(current.interface),
        self:GetDataFlavor()
    )
end

Environment:Refresh()
