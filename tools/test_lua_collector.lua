-- Offline collector logic tests for ForeverITA.
-- This file is a development tool and is never loaded by WoW.

local FIT = {
    version = "0.0.2-alpha",
    Compat = {},
}

_G.ForeverITA_NS = FIT

local diagnostics = {}
local db = {
    schema = 4,
    recordSchema = 3,
    missing = {},
    modified = {},
    incomplete = {},
    verifyClassic = {},
    dropped = 0,
    diagnostics = diagnostics,
    tests = {},
}

local flavor = "classic"

FIT.Compat.Storage = {
    GetCollectorDB = function()
        return db
    end,
    RecordDiagnostic = function(_, key)
        diagnostics[key] = (diagnostics[key] or 0) + 1
    end,
}

FIT.Compat.Client = {
    GetDataFlavor = function()
        return flavor
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

loadAddonFile("Core/DataRegistry.lua")
loadAddonFile("Core/RecordFormat.lua")
loadAddonFile("Modules/MissingQuestCollector.lua")

local Collector = assert(FIT.MissingQuestCollector)
local Data = assert(FIT.Data)
local RecordFormat = assert(FIT.RecordFormat)

local function expect(condition, message)
    if not condition then
        error(message or "aspettativa fallita")
    end
end

local function resetDB()
    for _, name in ipairs({ "missing", "modified", "incomplete", "verifyClassic" }) do
        db[name] = {}
    end
    db.dropped = 0
    db.diagnostics = diagnostics
    for key in pairs(diagnostics) do
        diagnostics[key] = nil
    end
end

local function snapshot(id, fields)
    local value = {
        id = id,
        privacySafe = true,
        zone = "Synthetic Zone",
        mapID = 999,
        build = {
            version = "test",
            build = "0",
            interface = 11509,
            flavor = flavor,
        },
    }

    for key, item in pairs(fields or {}) do
        value[key] = item
    end

    return value
end

local function hashes(fields)
    local result = {}
    for field, value in pairs(fields) do
        result[field] = RecordFormat:FingerprintField(field, value)
    end
    return result
end

local function registerClassic(id, fields)
    local record = {}
    for key, value in pairs(fields) do
        record[key] = value
    end
    record._sourceHashes = hashes(fields)
    record._meta = {
        synthetic = true,
        provenance = "ForeverITA offline collector test",
    }
    Data:RegisterQuest("classic", id, record)
end

-- 1) Missing quest + multi-event merge.
resetDB()
Collector:Observe(snapshot(990001001, {
    title = "Missing Test",
    description = "First detail",
}))
expect(db.missing[990001001] ~= nil, "missing quest non registrata")
expect(
    db.missing[990001001].content.description == "First detail",
    "description missing non conservata"
)

Collector:Observe(snapshot(990001001, {
    title = "Missing Test",
    completion = "Final text",
}))
expect(
    db.missing[990001001].content.description == "First detail",
    "merge multi-evento ha perso description"
)
expect(
    db.missing[990001001].content.completion == "Final text",
    "merge multi-evento non ha aggiunto completion"
)
expect(
    db.missing[990001001].fieldHashes.description
        == RecordFormat:FingerprintField("description", "First detail"),
    "fieldHashes description errato"
)

-- 2) Translation exists but observed field is missing from translation.
registerClassic(990001002, {
    title = "Incomplete Test",
    description = "Translated description source",
})
resetDB()
Collector:Observe(snapshot(990001002, {
    title = "Incomplete Test",
    completion = "Untranslated completion source",
}))
expect(db.incomplete[990001002] ~= nil, "incomplete non registrato")
expect(db.modified[990001002] == nil, "incomplete classificato come modified")
expect(
    db.incomplete[990001002].content.completion == "Untranslated completion source",
    "incomplete non conserva il campo mancante"
)
expect(
    db.incomplete[990001002].content.title == nil,
    "incomplete conserva un campo già tradotto non necessario"
)

-- 3) A real source mismatch must survive a later unrelated matching event.
registerClassic(990001003, {
    title = "Modified Test",
    description = "Expected description",
    completion = "Expected completion",
})
resetDB()
Collector:Observe(snapshot(990001003, {
    title = "Modified Test",
    description = "Changed description",
}))
expect(db.modified[990001003] ~= nil, "modified non registrato")
expect(
    db.modified[990001003].content.description == "Changed description",
    "modified non conserva la descrizione cambiata"
)

Collector:Observe(snapshot(990001003, {
    title = "Modified Test",
    completion = "Expected completion",
}))
expect(db.modified[990001003] ~= nil, "modified perso dopo evento non correlato")
expect(
    db.modified[990001003].content.description == "Changed description",
    "evidenza modified persa dopo completion uguale"
)

-- 4) On Forever, matching Classic data goes to verifyClassic.
registerClassic(990001004, {
    title = "Forever Verification Test",
    description = "Same source on Classic",
})
resetDB()
flavor = "forever"
Collector:Observe(snapshot(990001004, {
    title = "Forever Verification Test",
    description = "Same source on Classic",
}))
expect(db.verifyClassic[990001004] ~= nil, "verifyClassic non registrato")
expect(db.modified[990001004] == nil, "verifyClassic classificato come modified")

-- 5) A source mismatch has priority over verifyClassic.
resetDB()
Collector:Observe(snapshot(990001004, {
    title = "Forever Verification Test",
    description = "Forever changed source",
}))
expect(db.modified[990001004] ~= nil, "modified non prevale su verifyClassic")
expect(db.verifyClassic[990001004] == nil, "verifyClassic non ripulito dopo modified")

-- 6) Privacy fail-closed.
resetDB()
flavor = "classic"
local unsafe = snapshot(990001005, {
    title = "Potentially personalized text",
})
unsafe.privacySafe = false
Collector:Observe(unsafe)
expect(db.missing[990001005] == nil, "collector ha salvato uno snapshot privacy-unsafe")
expect(
    diagnostics.collector_privacy_alias_unavailable == 1,
    "diagnostica privacy fail-closed mancante"
)

-- 7) Unknown flavor fail-closed.
resetDB()
flavor = "unknown"
Collector:Observe(snapshot(990001006, {
    title = "Unknown flavor text",
}))
expect(db.missing[990001006] == nil, "collector ha salvato su flavor sconosciuto")
expect(
    diagnostics.collector_unsupported_flavor == 1,
    "diagnostica unsupported flavor mancante"
)

-- 8) A previously missing quest is cleared once a complete translation is registered.
resetDB()
flavor = "classic"
Collector:Observe(snapshot(990001007, {
    title = "Later translated",
    description = "Stable source",
}))
expect(db.missing[990001007] ~= nil, "precondizione missing fallita")

registerClassic(990001007, {
    title = "Later translated",
    description = "Stable source",
})
Collector:Observe(snapshot(990001007, {
    title = "Later translated",
    description = "Stable source",
}))
expect(db.missing[990001007] == nil, "missing non ripulito dopo aggiunta traduzione")
expect(db.modified[990001007] == nil, "traduzione stabile marcata modified")
expect(db.incomplete[990001007] == nil, "traduzione stabile marcata incomplete")

print("ForeverITA offline collector tests: PASS")
