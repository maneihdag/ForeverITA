local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local QuestDebug = {
    lastSnapshot = nil,
    autoPrint = true,
}

FIT.QuestDebug = QuestDebug

local function compact(text, limit)
    if text == nil then
        return "<nessun dato>"
    end

    text = tostring(text):gsub("\r", ""):gsub("\n", " ")
    limit = limit or 240

    if #text > limit then
        return text:sub(1, limit) .. "..."
    end

    return text
end

function QuestDebug:PrintSnapshot(snapshot)
    FIT:Print("----- QUEST DEBUG -----")
    FIT:Print("Evento: " .. tostring(snapshot.event))

    if snapshot.id then
        FIT:Print("QuestID: " .. tostring(snapshot.id))
    else
        FIT:Print("QuestID: <non disponibile>")
    end

    if snapshot.title then
        FIT:Print("Titolo: " .. compact(snapshot.title))
    end
    if snapshot.description then
        FIT:Print("Descrizione: " .. compact(snapshot.description))
    end
    if snapshot.objectives then
        FIT:Print("Obiettivi: " .. compact(snapshot.objectives))
    end
    if snapshot.progress then
        FIT:Print("Progress: " .. compact(snapshot.progress))
    end
    if snapshot.completion then
        FIT:Print("Completion: " .. compact(snapshot.completion))
    end

    if snapshot.id and FIT.Data then
        local flavor = FIT.Environment and FIT.Environment:GetDataFlavor() or "unknown"
        local _, source = FIT.Data:ResolveQuest(snapshot.id, flavor)
        FIT:Print("Traduzione: " .. tostring(source))
    end

    local errorCount = 0
    for field, err in pairs(snapshot.errors or {}) do
        errorCount = errorCount + 1
        FIT:Print("API " .. tostring(field) .. ": " .. tostring(err))
    end

    if errorCount == 0 then
        FIT:Print("API richieste: nessun errore rilevato.")
    end

    FIT:Print("-----------------------")
end

function QuestDebug:Capture(eventName)
    if not FIT.QuestAPI or not FIT.QuestAPI.Read then
        FIT:Print("QuestAPI non disponibile.")
        return nil
    end

    local snapshot = FIT.QuestAPI:Read(eventName)
    self.lastSnapshot = snapshot

    if FIT.MissingQuestCollector and FIT.MissingQuestCollector.Observe then
        FIT.MissingQuestCollector:Observe(snapshot)
    end

    if self.autoPrint then
        self:PrintSnapshot(snapshot)
    end

    return snapshot
end

function QuestDebug:DumpCurrent()
    if self.lastSnapshot then
        self:PrintSnapshot(self.lastSnapshot)
        return
    end

    local snapshot = FIT.QuestAPI and FIT.QuestAPI:Read(nil)
    if snapshot then
        self.lastSnapshot = snapshot
        self:PrintSnapshot(snapshot)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

frame:SetScript("OnEvent", function(_, event)
    QuestDebug:Capture(event)
end)
