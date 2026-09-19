local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    _G.ForeverITA_NS = _G.ForeverITA_NS or {}
    FIT = _G.ForeverITA_NS
end

FIT.name = addonName or "ForeverITA"
FIT.version = "0.0.2-alpha"
FIT.prefix = "|cff00ccff[ForeverITA]|r"
FIT.Compat = FIT.Compat or {}

function FIT:Print(message)
    print(self.prefix .. " " .. tostring(message))
end

local function printHelp()
    FIT:Print("Comandi principali:")
    FIT:Print("/fit status - stato client")
    FIT:Print("/fit quest - ultima quest letta")
    FIT:Print("/fit data <QuestID> - controlla i dati italiani")
    FIT:Print("/fit show <QuestID> - apre la traduzione di prova")
    FIT:Print("/fit selftest - test logica Classic/Forever")
    FIT:Print("/fit classictest - controlli per Classic Era")
    FIT:Print("/fit ui - apre/chiude una finestra di test")
    FIT:Print("/fit svtest start|check - test SavedVariables")
end

local function handleSlash(message)
    message = message or ""
    message = message:match("^%s*(.-)%s*$") or ""

    local command, rest = message:match("^(%S*)%s*(.-)$")
    command = (command or ""):lower()

    if command == "" or command == "status" then
        FIT:Print("ForeverITA " .. FIT.version)

        if FIT.Compat.Client and FIT.Compat.Client.Describe then
            FIT:Print(FIT.Compat.Client:Describe())
        else
            FIT:Print("Compat/Client non disponibile.")
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
            FIT:Print("QuestDebug non disponibile.")
        end
        return
    end

    if command == "data" then
        local questID = tonumber(rest)
        if not questID then
            FIT:Print("Uso: /fit data <QuestID>")
            return
        end

        if not FIT.Data or not FIT.Data.ResolveQuest then
            FIT:Print("DataRegistry non disponibile.")
            return
        end

        local flavor = "unknown"
        if FIT.Compat.Client and FIT.Compat.Client.GetDataFlavor then
            flavor = FIT.Compat.Client:GetDataFlavor()
        end

        local record, source = FIT.Data:ResolveQuest(questID, flavor)
        if record then
            FIT:Print("Quest " .. questID .. " -> " .. tostring(source))
            FIT:Print("Titolo IT: " .. tostring(record.title or "<mancante>"))
        else
            FIT:Print("Quest " .. questID .. " -> nessuna traduzione (" .. tostring(source) .. ")")
        end
        return
    end


    if command == "show" then
        local questID = tonumber(rest)
        if not questID then
            FIT:Print("Uso: /fit show <QuestID>")
            return
        end

        if FIT.QuestTranslation and FIT.QuestTranslation.ShowByID then
            local ok = FIT.QuestTranslation:ShowByID(questID)
            if not ok then
                FIT:Print("Nessuna traduzione disponibile per la quest " .. tostring(questID) .. ".")
            end
        else
            FIT:Print("Modulo traduzione non disponibile.")
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

    if command == "classictest" then
        if FIT.ClassicSmokeTest and FIT.ClassicSmokeTest.Run then
            FIT.ClassicSmokeTest:Run()
        else
            FIT:Print("ClassicSmokeTest non disponibile.")
        end
        return
    end

    if command == "ui" then
        if FIT.Compat.UI and FIT.Compat.UI.ToggleTestWindow then
            FIT.Compat.UI:ToggleTestWindow()
        else
            FIT:Print("Compat/UI non disponibile.")
        end
        return
    end

    if command == "svtest" then
        local action = (rest or ""):lower()

        if not FIT.Compat.Storage then
            FIT:Print("Compat/Storage non disponibile.")
            return
        end

        if action == "start" then
            local ok, messageText = FIT.Compat.Storage:StartPersistenceProbe()
            FIT:Print(messageText)
            if ok then
                FIT:Print("Ora usa /reload e poi /fit svtest check")
            end
            return
        end

        if action == "check" then
            local ok, messageText = FIT.Compat.Storage:CheckPersistenceProbe()
            FIT:Print(messageText)
            return
        end

        FIT:Print("Uso: /fit svtest start  oppure  /fit svtest check")
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

    if FIT.Compat.Storage and FIT.Compat.Storage.Initialize then
        FIT.Compat.Storage:Initialize()
    end

    self:UnregisterEvent("ADDON_LOADED")
end)
