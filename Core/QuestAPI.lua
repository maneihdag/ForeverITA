local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local QuestAPI = {}
FIT.QuestAPI = QuestAPI

local function read(snapshot, field, apiName, ...)
    local value, err = FIT:SafeGlobalCall(apiName, ...)

    if value ~= nil then
        snapshot[field] = value
    elseif err then
        snapshot.errors[field] = err
    end
end

function QuestAPI:Read(eventName)
    local snapshot = {
        event = eventName or "MANUAL",
        errors = {},
    }

    read(snapshot, "id", "GetQuestID")

    if eventName == "QUEST_DETAIL" or eventName == nil then
        read(snapshot, "title", "GetTitleText")
        read(snapshot, "description", "GetQuestText")
        read(snapshot, "objectives", "GetObjectiveText")
    elseif eventName == "QUEST_PROGRESS" then
        read(snapshot, "title", "GetTitleText")
        read(snapshot, "progress", "GetProgressText")
    elseif eventName == "QUEST_COMPLETE" then
        read(snapshot, "title", "GetTitleText")
        read(snapshot, "completion", "GetRewardText")
    else
        read(snapshot, "title", "GetTitleText")
    end

    if eventName == nil then
        read(snapshot, "progress", "GetProgressText")
        read(snapshot, "completion", "GetRewardText")
    end

    if eventName == "QUEST_DETAIL" or eventName == "QUEST_COMPLETE" or eventName == nil then
        read(snapshot, "npcGUID", "UnitGUID", "npc")
        read(snapshot, "npcName", "UnitName", "npc")
    end

    if FIT.Environment and FIT.Environment.GetBuildSnapshot then
        snapshot.build = FIT.Environment:GetBuildSnapshot()
    end

    return snapshot
end
