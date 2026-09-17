local addonName, FIT = ...

local frame = CreateFrame("Frame")

local events = {
    "QUEST_DETAIL",
    "QUEST_PROGRESS",
    "QUEST_COMPLETE",
}

for _, eventName in ipairs(events) do
    frame:RegisterEvent(eventName)
end

local function SafeCall(apiName)
    local func = _G[apiName]

    if type(func) ~= "function" then
        return nil, "API non disponibile: " .. apiName
    end

    local success, result = pcall(func)

    if not success then
        return nil, "Errore " .. apiName .. ": " .. tostring(result)
    end

    return result, nil
end

local function CleanText(text)
    if text == nil then
        return "<nessun dato>"
    end

    text = tostring(text)
    text = text:gsub("\r", "")
    text = text:gsub("\n", " ")

    if #text > 400 then
        text = text:sub(1, 400) .. "..."
    end

    return text
end

function FIT:DumpCurrentQuest(source)
    FIT:Print("----- QUEST DEBUG -----")

    if source then
        FIT:Print("Evento: " .. tostring(source))
    end

    local questID, questIDError = SafeCall("GetQuestID")
    local title, titleError = SafeCall("GetTitleText")
    local description, descriptionError = SafeCall("GetQuestText")
    local objectives, objectivesError = SafeCall("GetObjectiveText")

    if questIDError then
        FIT:Print(questIDError)
    else
        FIT:Print("QuestID: " .. tostring(questID))
    end

    if titleError then
        FIT:Print(titleError)
    else
        FIT:Print("Titolo: " .. CleanText(title))
    end

    if descriptionError then
        FIT:Print(descriptionError)
    else
        FIT:Print("Descrizione: " .. CleanText(description))
    end

    if objectivesError then
        FIT:Print(objectivesError)
    else
        FIT:Print("Obiettivi: " .. CleanText(objectives))
    end

    FIT:Print("-----------------------")
end

frame:SetScript("OnEvent", function(self, event)
    FIT:DumpCurrentQuest(event)
end)
