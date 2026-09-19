local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local SelfTest = {}
FIT.SelfTest = SelfTest

local function equal(actual, expected)
    return actual == expected
end

function SelfTest:Run()
    if not FIT.Data then
        FIT:Print("SELFTEST FAIL: DataRegistry non disponibile.")
        return false
    end

    local passed, failed = 0, 0

    local function check(name, condition)
        if condition then
            passed = passed + 1
            FIT:Print("SELFTEST PASS: " .. name)
        else
            failed = failed + 1
            FIT:Print("SELFTEST FAIL: " .. name)
        end
    end

    local classic, classicSource = FIT.Data:ResolveQuest(990000001, "classic")
    check("Classic fixture trovata", classic ~= nil and classicSource == "classic")
    check("Classic title", classic and equal(classic.title, "[TEST] Base Classic"))

    local forever, foreverSource = FIT.Data:ResolveQuest(990000001, "forever")
    check("Forever override applicato", forever ~= nil and foreverSource == "forever_override")
    check("Forever title prevale", forever and equal(forever.title, "[TEST] Override Forever"))
    check(
        "Campo non sovrascritto resta Classic",
        forever and equal(forever.objectives, "Verifica il fallback dei campi non sovrascritti.")
    )

    local foreverOnly, foreverOnlySource = FIT.Data:ResolveQuest(990000002, "forever")
    check("Forever-only disponibile", foreverOnly ~= nil and foreverOnlySource == "forever")

    local classicNoForeverOnly = FIT.Data:ResolveQuest(990000002, "classic")
    check("Forever-only assente su Classic", classicNoForeverOnly == nil)

    local missing, missingSource = FIT.Data:ResolveQuest(990000003, "forever")
    check("Quest sconosciuta resta missing", missing == nil and missingSource == "missing")


    if FIT.RecordFormat then
        local baseSnapshot = {
            id = 990000010,
            title = "Titolo",
            description = "Descrizione",
            objectives = "Obiettivi",
            zone = "Elwynn Forest",
            mapID = 37,
        }

        local otherZone = {
            id = 990000010,
            title = "Titolo",
            description = "Descrizione",
            objectives = "Obiettivi",
            zone = "Stormwind City",
            mapID = 84,
        }

        local changedText = {
            id = 990000010,
            title = "Titolo modificato",
            description = "Descrizione",
            objectives = "Obiettivi",
            zone = "Elwynn Forest",
            mapID = 37,
        }

        local hashA = FIT.RecordFormat:Fingerprint(baseSnapshot.id, FIT.RecordFormat:BuildContent(baseSnapshot))
        local hashB = FIT.RecordFormat:Fingerprint(otherZone.id, FIT.RecordFormat:BuildContent(otherZone))
        local hashC = FIT.RecordFormat:Fingerprint(changedText.id, FIT.RecordFormat:BuildContent(changedText))

        check("Hash uguale se cambia solo la zona", hashA == hashB)
        check("Hash cambia se cambia il testo", hashA ~= hashC)

        local firstEvent = FIT.RecordFormat:BuildRecord({
            id = 990000011,
            title = "Quest test",
            description = "Descrizione iniziale",
            objectives = "Obiettivi iniziali",
        }, "translation_missing", "missing")

        local secondEvent = FIT.RecordFormat:BuildRecord({
            id = 990000011,
            title = "Quest test",
            completion = "Testo finale",
        }, "translation_missing", "missing", firstEvent)

        check("Merge conserva descrizione", secondEvent.content.description == "Descrizione iniziale")
        check("Merge conserva obiettivi", secondEvent.content.objectives == "Obiettivi iniziali")
        check("Merge aggiunge completion", secondEvent.content.completion == "Testo finale")
    else
        check("RecordFormat disponibile", false)
    end
    FIT:Print(string.format("SELFTEST: %d pass, %d fail", passed, failed))
    return failed == 0
end
