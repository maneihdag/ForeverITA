local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    _G.ForeverITA_NS = _G.ForeverITA_NS or {}
    FIT = _G.ForeverITA_NS
end

FIT.name = addonName or "ForeverITA"
FIT.version = "0.0.2-alpha"
FIT.prefix = "|cff00ccff[ForeverITA]|r"

function FIT:Print(message)
    print(self.prefix .. " " .. tostring(message))
end

function FIT:ToPlainValue(value)
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

function FIT:SafeGlobalCall(apiName, ...)
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

local function printHelp()
    FIT:Print("Comandi:")
    FIT:Print("/fit status - client, build e flavor dati")
    FIT:Print("/fit quest - snapshot della quest corrente")
    FIT:Print("/fit data <QuestID> - risoluzione Classic/Forever")
    FIT:Print("/fit collector - stato raccolta testi mancanti")
    FIT:Print("/fit selftest - test del sistema dati e override")
end

local function handleSlash(message)
    message = message or ""
    message = message:match("^%s*(.-)%s*$") or ""

    local command, rest = message:match("^(%S*)%s*(.-)$")
    command = (command or ""):lower()

    if command == "" or command == "status" then
        FIT:Print("ForeverITA " .. FIT.version)

        if FIT.Environment and FIT.Environment.Describe then
            FIT:Print(FIT.Environment:Describe())
        else
            FIT:Print("Environment non disponibile.")
        end

        return
    end

    if command == "help" then
        printHelp()
        return
    end

    if command == "quest" then
        if FIT.QuestDebug and FIT.QuestDebug.DumpCurrent then
            FIT.QuestDebug:DumpCurrent()
        else
            FIT:Print("Modulo QuestDebug non disponibile.")
        end
        return
    end

    if command == "data" then
        local questID = tonumber(rest)
        if not questID then
            FIT:Print("Uso: /fit data <QuestID>")
            return
        end

        if FIT.Data and FIT.Data.ResolveQuest then
            local flavor = FIT.Environment and FIT.Environment:GetDataFlavor() or "unknown"
            local record, source = FIT.Data:ResolveQuest(questID, flavor)
            if record then
                FIT:Print("Quest " .. questID .. " -> " .. tostring(source))
                FIT:Print("Titolo IT: " .. tostring(record.title or "<mancante>"))
            else
                FIT:Print("Quest " .. questID .. " -> nessuna traduzione (" .. tostring(source) .. ")")
            end
        else
            FIT:Print("DataRegistry non disponibile.")
        end
        return
    end

    if command == "collector" then
        if FIT.MissingQuestCollector and FIT.MissingQuestCollector.PrintStatus then
            FIT.MissingQuestCollector:PrintStatus()
        else
            FIT:Print("Collector non disponibile.")
        end
        return
    end

    if command == "selftest" then
        if FIT.SelfTest and FIT.SelfTest.Run then
            FIT.SelfTest:Run()
        else
            FIT:Print("SelfTest non disponibile.")
        end
        return
    end

    printHelp()
end

SLASH_FOREVERITA1 = "/fit"
SlashCmdList["FOREVERITA"] = handleSlash

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event ~= "ADDON_LOADED" or loadedAddon ~= FIT.name then
        return
    end

    FIT:Print("Addon caricato. Versione " .. FIT.version)
    self:UnregisterEvent("ADDON_LOADED")
end)
