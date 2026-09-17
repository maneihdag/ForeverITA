local addonName, FIT = ...

FIT.name = addonName
FIT.version = "0.0.1-alpha"
FIT.prefix = "|cff00ccff[ForeverITA]|r"

function FIT:Print(message)
    print(self.prefix .. " " .. tostring(message))
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event ~= "ADDON_LOADED" then
        return
    end

    if loadedAddon ~= addonName then
        return
    end

    FIT:Print("Addon caricato.")
    FIT:Print("Versione " .. FIT.version)

    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_FOREVERITA1 = "/fit"

SlashCmdList["FOREVERITA"] = function(message)
    message = message or ""
    message = message:match("^%s*(.-)%s*$")
    message = message:lower()

    if message == "quest" then
        if FIT.DumpCurrentQuest then
            FIT:DumpCurrentQuest("manual")
        else
            FIT:Print("Modulo QuestDebug non disponibile.")
        end

        return
    end

    local version, build, buildDate, interfaceVersion = GetBuildInfo()

    FIT:Print("ForeverITA " .. FIT.version)
    FIT:Print("Client: " .. tostring(version))
    FIT:Print("Build: " .. tostring(build))
    FIT:Print("Interface: " .. tostring(interfaceVersion))
    FIT:Print("Comandi: /fit | /fit quest")
end
