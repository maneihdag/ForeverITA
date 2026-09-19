local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local API = {}
FIT.Compat.API = API

function API:ToPlainValue(value)
    if value == nil then
        return nil, nil
    end

    if type(_G.issecretvalue) == "function" then
        local okSecret, isSecret = pcall(_G.issecretvalue, value)

        if okSecret and isSecret then
            if type(_G.canaccessvalue) ~= "function" then
                return nil, "secret_value"
            end

            local okAccess, canAccess = pcall(_G.canaccessvalue, value)
            if not okAccess or not canAccess then
                return nil, "secret_value"
            end
        end
    end

    local valueType = type(value)
    if valueType ~= "string" and valueType ~= "number" and valueType ~= "boolean" then
        return nil, "unsupported_type:" .. valueType
    end

    return value, nil
end

function API:CallGlobal(apiName, ...)
    local func = _G[apiName]
    if type(func) ~= "function" then
        return nil, "missing_api:" .. apiName
    end

    local ok, result = pcall(func, ...)
    if not ok then
        return nil, "api_error:" .. apiName
    end

    local plain, reason = self:ToPlainValue(result)
    if reason then
        return nil, reason .. ":" .. apiName
    end

    return plain, nil
end
