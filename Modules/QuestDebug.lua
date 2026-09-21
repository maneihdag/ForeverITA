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
    seenEvents = 0,
    autoPrint = false,
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

    if snapshot.privacySafe == false then
        FIT:Print("Testo quest non mostrato: privacy alias non disponibile.")
    else
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
    end

    if snapshot.id and FIT.Data then
        local flavor = "unknown"
        if FIT.Compat.Client and FIT.Compat.Client.GetDataFlavor then
            flavor = FIT.Compat.Client:GetDataFlavor()
        end

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

function QuestDebug:Capture(eventName, snapshot)
    local Quest = FIT.Compat.Quest
    if not Quest or not Quest.Read then
        if FIT.Compat.Storage and FIT.Compat.Storage.RecordDiagnostic then
            FIT.Compat.Storage:RecordDiagnostic("quest_compat_missing")
        end
        return nil
    end

    snapshot = snapshot or Quest:Read(eventName)
    self.lastSnapshot = snapshot
    self.seenEvents = self.seenEvents + 1

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

    local Quest = FIT.Compat.Quest
    local snapshot = Quest and Quest:Read(nil)

    if snapshot then
        self.lastSnapshot = snapshot
        self:PrintSnapshot(snapshot)
    else
        FIT:Print("Nessuna quest letta finora.")
    end
end

if FIT.Compat.Quest and FIT.Compat.Quest.RegisterListener then
    FIT.Compat.Quest:RegisterListener(function(event, snapshot)
        if event ~= "QUEST_FINISHED" then
            QuestDebug:Capture(event, snapshot)
        end
    end)
end
