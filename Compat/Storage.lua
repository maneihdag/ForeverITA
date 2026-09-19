local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local Storage = {
    schema = 1,
    ready = false,
}

FIT.Compat.Storage = Storage

local function newDatabase()
    return {
        schema = Storage.schema,
        missing = {},
        verifyClassic = {},
        dropped = 0,
        tests = {},
    }
end

function Storage:Initialize()
    local db = _G.ForeverITA_CollectorDB

    if type(db) ~= "table" or db.schema ~= self.schema then
        db = newDatabase()
    end

    db.missing = type(db.missing) == "table" and db.missing or {}
    db.verifyClassic = type(db.verifyClassic) == "table" and db.verifyClassic or {}
    db.tests = type(db.tests) == "table" and db.tests or {}
    db.dropped = tonumber(db.dropped) or 0

    if FIT.Compat.Client and FIT.Compat.Client.GetBuildSnapshot then
        db.lastBuild = FIT.Compat.Client:GetBuildSnapshot()
    end

    _G.ForeverITA_CollectorDB = db
    self.ready = true
end

function Storage:IsReady()
    return self.ready == true
end

function Storage:GetCollectorDB()
    if not self.ready then
        return nil
    end

    return _G.ForeverITA_CollectorDB
end

function Storage:StartPersistenceProbe()
    local db = self:GetCollectorDB()
    if not db then
        return false, "SavedVariables non ancora pronte."
    end

    db.tests.savedVariablesProbe = {
        marker = "ForeverITA-SV-PROBE-1",
        build = FIT.Compat.Client and FIT.Compat.Client:GetBuildSnapshot() or nil,
    }

    return true, "Test SavedVariables preparato."
end

function Storage:CheckPersistenceProbe()
    local db = self:GetCollectorDB()
    if not db then
        return false, "FAIL: SavedVariables non disponibili."
    end

    local probe = db.tests and db.tests.savedVariablesProbe
    if type(probe) == "table" and probe.marker == "ForeverITA-SV-PROBE-1" then
        db.tests.lastSavedVariablesResult = "pass"
        db.tests.savedVariablesProbe = nil
        return true, "PASS: il dato è sopravvissuto al /reload."
    end

    db.tests.lastSavedVariablesResult = "fail"
    return false, "FAIL: il dato di prova non è stato ritrovato dopo il /reload."
end
