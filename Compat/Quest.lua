local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local Quest = {
    listeners = {},
    eventFrame = nil,
}

FIT.Compat.Quest = Quest

local function read(snapshot, field, apiName, ...)
    local API = FIT.Compat.API
    if not API then
        snapshot.errors[field] = "compat_api_missing"
        return
    end

    local value, err = API:CallGlobal(apiName, ...)

    if value ~= nil then
        snapshot[field] = value
    elseif err then
        snapshot.errors[field] = err
    end
end

function Quest:Read(eventName)
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

    if FIT.Compat.Client and FIT.Compat.Client.GetBuildSnapshot then
        snapshot.build = FIT.Compat.Client:GetBuildSnapshot()
    end

    return snapshot
end

function Quest:RegisterListener(callback)
    if type(callback) ~= "function" then
        return false
    end

    self.listeners[#self.listeners + 1] = callback

    if self.eventFrame then
        return true
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_PROGRESS")
    frame:RegisterEvent("QUEST_COMPLETE")

    frame:SetScript("OnEvent", function(_, event)
        for _, listener in ipairs(Quest.listeners) do
            local ok = pcall(listener, event)
            if not ok then
                FIT:Print("Errore nel listener quest.")
            end
        end
    end)

    self.eventFrame = frame
    return true
end
