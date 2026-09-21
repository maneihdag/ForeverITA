-- Offline SavedVariables migration tests for ForeverITA.
-- This file is a development tool and is never loaded by WoW.

local FIT = {
    version = "0.0.2-alpha",
    Compat = {},
}

_G.ForeverITA_NS = FIT

FIT.Compat.Client = {
    GetBuildSnapshot = function()
        return {
            version = "test",
            build = "0",
            interface = 11509,
            flavor = "classic",
        }
    end,
}

local function loadAddonFile(path)
    local chunk, err = loadfile(path)
    if not chunk then
        error("Impossibile caricare " .. path .. ": " .. tostring(err))
    end

    local ok, runErr = pcall(chunk, "ForeverITA", FIT)
    if not ok then
        error("Errore eseguendo " .. path .. ": " .. tostring(runErr))
    end
end

local function expect(condition, message)
    if not condition then
        error(message or "aspettativa fallita")
    end
end

loadAddonFile("Core/RecordFormat.lua")

local oldContent = {
    title = "Old collected title",
    description = "Old collected description",
}

_G.ForeverITA_CollectorDB = {
    schema = 3,
    recordSchema = 2,
    addonVersion = "0.0.1-alpha",
    missing = {
        [990002001] = {
            schema = 2,
            type = "quest",
            id = 990002001,
            reason = "translation_missing",
            sourceAtCapture = "missing",
            content = oldContent,
            context = {
                zone = "Old Zone",
                mapID = 1,
            },
            contentHash = "q2-123",
            addonVersion = "0.0.1-alpha",
            client = {
                version = "1.15.9",
                build = "69722",
                interface = 11509,
                flavor = "classic",
            },
            revision = 5,
        },
    },
    verifyClassic = {},
    modified = {},
    dropped = 2,
    diagnostics = {
        old_counter = 3,
    },
    tests = {
        old_test = "kept",
    },
}

loadAddonFile("Compat/Storage.lua")
FIT.Compat.Storage:Initialize()

local db = _G.ForeverITA_CollectorDB
local record = db.missing[990002001]

expect(db.schema == 4, "database schema non migrato a 4")
expect(db.recordSchema == 3, "recordSchema non migrato a 3")
expect(type(db.incomplete) == "table", "bucket incomplete non creato")
expect(record ~= nil, "record schema 2 perso durante migrazione")
expect(record.schema == 3, "record non migrato a schema 3")
expect(record.revision == 5, "revision alterata durante migrazione")
expect(record.content.title == oldContent.title, "contenuto perso durante migrazione")
expect(
    record.fieldHashes.title
        == FIT.RecordFormat:FingerprintField("title", oldContent.title),
    "fieldHashes non rigenerato correttamente"
)
expect(
    record.contentHash
        == FIT.RecordFormat:Fingerprint(record.id, record.content),
    "contentHash non rigenerato con schema corrente"
)
expect(db.dropped == 2, "dropped non preservato")
expect(db.diagnostics.old_counter == 3, "diagnostica precedente non preservata")
expect(
    db.diagnostics.storage_migrated_v3_to_v4 == 1,
    "diagnostica migrazione mancante"
)
expect(db.tests.old_test == "kept", "test metadata non preservati")

-- Unknown/older database schemas still reset safely.
_G.ForeverITA_CollectorDB = {
    schema = 2,
    recordSchema = 1,
    missing = {
        [1] = { schema = 1 },
    },
}

FIT.Compat.Storage:Initialize()
local resetDB = _G.ForeverITA_CollectorDB
expect(resetDB.schema == 4, "schema sconosciuto non resettato")
expect(next(resetDB.missing) == nil, "dati incompatibili non resettati")
expect(resetDB.recordSchema == 3, "recordSchema reset errato")

print("ForeverITA offline storage migration tests: PASS")
