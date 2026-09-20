-- Offline logic harness for ForeverITA core/data validation.
-- This file is a development tool and is never loaded by WoW.

local FIT = {
    version = "0.0.2-alpha",
    Compat = {},
}

_G.ForeverITA_NS = FIT

local output = {}

function FIT:Print(message)
    output[#output + 1] = tostring(message)
end

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
loadAddonFile("Compat/API.lua")
loadAddonFile("Compat/Privacy.lua")

loadAddonFile("Data/Classic_it/Quests.lua")
loadAddonFile("Data/Classic_it/Mulgore.lua")
loadAddonFile("Data/Forever_it/Quests.lua")

-- Real-shape synthetic data for metadata-only Forever verification.
local inheritedTitle = "[TEST] Metadata-only Forever verification"
local inheritedDescription = "Classic translation inherited on Forever."

FIT.Data:RegisterQuest("classic", 990000030, {
    title = inheritedTitle,
    description = inheritedDescription,
    _sourceHashes = {
        title = FIT.RecordFormat:FingerprintField("title", inheritedTitle),
        description = FIT.RecordFormat:FingerprintField("description", inheritedDescription),
    },
    _meta = {
        synthetic = false,
        status = "draft",
        sourceClient = "Classic synthetic",
        sourceBuild = "0",
        provenance = "ForeverITA offline core test",
    },
})

FIT.Data:RegisterQuest("forever", 990000030, {
    _meta = {
        synthetic = false,
        status = "verified_forever",
        sourceClient = "Forever synthetic",
        sourceBuild = "0",
        provenance = "ForeverITA offline core test",
    },
})

local inherited, inheritedSource = FIT.Data:ResolveQuest(990000030, "forever")
if not (
    inherited
    and inheritedSource == "forever_override"
    and inherited.title == inheritedTitle
    and inherited.description == inheritedDescription
    and inherited._meta.status == "verified_forever"
    and inherited._sourceHashes.title
        == FIT.RecordFormat:FingerprintField("title", inheritedTitle)
) then
    error("metadata-only Forever verification fallback non valido")
end

loadAddonFile("Dev/SelfTest.lua")
loadAddonFile("Dev/TranslationDataValidator.lua")

local selfTestOK = FIT.SelfTest and FIT.SelfTest:Run()
local dataTestOK = FIT.TranslationDataValidator
    and FIT.TranslationDataValidator:Run()

if not selfTestOK or not dataTestOK then
    for _, line in ipairs(output) do
        io.stderr:write(line .. "\n")
    end
    os.exit(1)
end

local sawDataPass = false
for _, line in ipairs(output) do
    if line == "DATATEST PASS" then
        sawDataPass = true
        break
    end
end

if not sawDataPass then
    for _, line in ipairs(output) do
        io.stderr:write(line .. "\n")
    end
    error("DATATEST PASS non trovato nell'output")
end

print("ForeverITA offline Lua core tests: PASS")
