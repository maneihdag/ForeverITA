local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local Translation = {}
FIT.QuestTranslation = Translation

local function flavor()
    if FIT.Compat.Client and FIT.Compat.Client.GetDataFlavor then
        return FIT.Compat.Client:GetDataFlavor()
    end
    return "unknown"
end

function Translation:ShowByID(questID)
    if not FIT.Data or not FIT.Compat.TranslationUI then
        return false
    end

    local record, source = FIT.Data:ResolveQuest(questID, flavor())
    if not record then
        return false
    end

    FIT.Compat.TranslationUI:ShowQuest(questID, record, source, nil)
    return true
end

local function hasBodyForEvent(record, event)
    if event == "QUEST_DETAIL" then
        return record.description ~= nil or record.objectives ~= nil
    end

    if event == "QUEST_PROGRESS" then
        return record.progress ~= nil
    end

    if event == "QUEST_COMPLETE" then
        return record.completion ~= nil
    end

    return true
end

function Translation:HandleSnapshot(event, snapshot)
    if event == "QUEST_FINISHED" then
        if FIT.Compat.TranslationUI then
            FIT.Compat.TranslationUI:Hide()
        end
        return
    end

    if type(snapshot) ~= "table" or type(snapshot.id) ~= "number" or snapshot.id <= 0 then
        return
    end

    local record, source = FIT.Data:ResolveQuest(snapshot.id, flavor())

    if record and hasBodyForEvent(record, event) then
        FIT.Compat.TranslationUI:ShowQuest(snapshot.id, record, source, event)
    elseif FIT.Compat.TranslationUI then
        FIT.Compat.TranslationUI:Hide()
    end
end

if FIT.Compat.Quest and FIT.Compat.Quest.RegisterListener then
    FIT.Compat.Quest:RegisterListener(function(event, snapshot)
        Translation:HandleSnapshot(event, snapshot)
    end)
end
