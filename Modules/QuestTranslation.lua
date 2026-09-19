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

    FIT.Compat.TranslationUI:ShowQuest(questID, record, source)
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

    if record then
        FIT.Compat.TranslationUI:ShowQuest(snapshot.id, record, source)
    elseif FIT.Compat.TranslationUI then
        FIT.Compat.TranslationUI:Hide()
    end
end

if FIT.Compat.Quest and FIT.Compat.Quest.RegisterListener then
    FIT.Compat.Quest:RegisterListener(function(event, snapshot)
        Translation:HandleSnapshot(event, snapshot)
    end)
end
