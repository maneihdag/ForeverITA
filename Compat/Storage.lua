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
    schema = 4,
    ready = false,
}

FIT.Compat.Storage = Storage

local function newDatabase()
    return {
        schema = Storage.schema,
        recordSchema = 3,
        addonVersion = FIT.version,
        missing = {},
        incomplete = {},
        verifyClassic = {},
        modified = {},
        dropped = 0,
        diagnostics = {},
        tests = {},
    }
end

local function migrateRecordV2ToV3(record)
    if type(record) ~= "table" then
        return nil
    end

    if record.schema == 3 then
        return record
    end

    if record.schema ~= 2
        or type(record.id) ~= "number"
        or type(record.content) ~= "table"
        or not FIT.RecordFormat
        or not FIT.RecordFormat.BuildFieldHashes
        or not FIT.RecordFormat.Fingerprint then
        return nil
    end

    record.schema = 3
    record.fieldHashes = FIT.RecordFormat:BuildFieldHashes(record.content)
    record.contentHash = FIT.RecordFormat:Fingerprint(record.id, record.content)
    record.addonVersion = FIT.version

    return record
end

local function migrateBucketV2ToV3(bucket)
    local migrated = {}

    if type(bucket) ~= "table" then
        return migrated
    end

    for questID, record in pairs(bucket) do
        local converted = migrateRecordV2ToV3(record)
        if converted then
            migrated[questID] = converted
        end
    end

    return migrated
end

local function migrateDatabaseV3ToV4(db)
    if type(db) ~= "table" or db.schema ~= 3 then
        return nil
    end

    db.schema = 4
    db.recordSchema = 3
    db.addonVersion = FIT.version
    db.missing = migrateBucketV2ToV3(db.missing)
    db.modified = migrateBucketV2ToV3(db.modified)
    db.verifyClassic = migrateBucketV2ToV3(db.verifyClassic)
    db.incomplete = type(db.incomplete) == "table" and db.incomplete or {}
    db.diagnostics = type(db.diagnostics) == "table" and db.diagnostics or {}
    db.tests = type(db.tests) == "table" and db.tests or {}
    db.dropped = tonumber(db.dropped) or 0

    db.diagnostics.storage_migrated_v3_to_v4 =
        (db.diagnostics.storage_migrated_v3_to_v4 or 0) + 1

    return db
end

function Storage:Initialize()
    local db = _G.ForeverITA_CollectorDB

    if type(db) == "table" and db.schema == 3 then
        db = migrateDatabaseV3ToV4(db)
    end

    if type(db) ~= "table" or db.schema ~= self.schema then
        db = newDatabase()
    end

    db.recordSchema = 3
    db.addonVersion = FIT.version
    db.missing = type(db.missing) == "table" and db.missing or {}
    db.incomplete = type(db.incomplete) == "table" and db.incomplete or {}
    db.verifyClassic = type(db.verifyClassic) == "table" and db.verifyClassic or {}
    db.modified = type(db.modified) == "table" and db.modified or {}
    db.diagnostics = type(db.diagnostics) == "table" and db.diagnostics or {}
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

function Storage:RecordDiagnostic(code)
    local db = self:GetCollectorDB()
    if not db or type(code) ~= "string" then
        return
    end

    db.diagnostics[code] = (db.diagnostics[code] or 0) + 1
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
