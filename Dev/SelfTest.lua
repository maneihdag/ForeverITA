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
    check(
        "Hash Forever sovrascrive solo il campo fornito",
        forever
            and forever._sourceHashes
            and forever._sourceHashes.title == "f3-2001"
            and forever._sourceHashes.description == "f3-1002"
            and forever._sourceHashes.objectives == "f3-1003"
    )
    check(
        "Metadati campi dinamici vengono uniti per campo",
        forever
            and forever._dynamicFields
            and forever._dynamicFields.title
            and forever._dynamicFields.description
            and forever._dynamicFields.title[1] == "class"
            and forever._dynamicFields.description[1] == "race"
    )

    local foreverOnly, foreverOnlySource = FIT.Data:ResolveQuest(990000002, "forever")
    check("Forever-only disponibile", foreverOnly ~= nil and foreverOnlySource == "forever")

    local classicNoForeverOnly = FIT.Data:ResolveQuest(990000002, "classic")
    check("Forever-only assente su Classic", classicNoForeverOnly == nil)

    local missing, missingSource = FIT.Data:ResolveQuest(990000003, "forever")
    check("Quest sconosciuta resta missing", missing == nil and missingSource == "missing")

    local unsupported, unsupportedSource = FIT.Data:ResolveQuest(990000001, "unknown")
    check(
        "Flavor sconosciuto non usa fallback Classic",
        unsupported == nil and unsupportedSource == "unsupported_flavor"
    )

    local duplicateAccepted = pcall(function()
        FIT.Data:RegisterQuest("classic", 990000001, {
            title = "[TEST] Duplicato non consentito",
        })
    end)
    check("QuestID duplicato nello stesso layer rifiutato", duplicateAccepted == false)

    if FIT.Data.ForEachQuest then
        local iterated = {}
        local firstRecord

        local iterOk = FIT.Data:ForEachQuest("classic", function(questID, record)
            iterated[#iterated + 1] = questID
            if not firstRecord then
                firstRecord = record
                record.title = "[TEST] Mutazione copia"
            end
        end)

        local sorted = true
        for i = 2, #iterated do
            if iterated[i - 1] > iterated[i] then
                sorted = false
                break
            end
        end

        check("Iterazione dati disponibile", iterOk == true and #iterated > 0)
        check("Iterazione dati ordinata per QuestID", sorted)

        local fixtureAfterIteration = FIT.Data:ResolveQuest(990000001, "classic")
        check(
            "Iterazione dati non espone record mutabili",
            fixtureAfterIteration
                and fixtureAfterIteration.title == "[TEST] Base Classic"
        )
    else
        check("Iterazione dati disponibile", false)
    end


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

        local normalizedA = FIT.RecordFormat:FingerprintField("description", "Riga uno\r\nRiga due\r\n")
        local normalizedB = FIT.RecordFormat:FingerprintField("description", "Riga uno\nRiga due")
        local internalSpaceA = FIT.RecordFormat:FingerprintField("description", "A  B")
        local internalSpaceB = FIT.RecordFormat:FingerprintField("description", "A B")

        check("Normalizzazione CRLF/LF stabile", normalizedA == normalizedB)
        check("Trim esterno non cambia hash", FIT.RecordFormat:FingerprintField("title", "  Test  ") == FIT.RecordFormat:FingerprintField("title", "Test"))
        check("Spazi interni restano significativi", internalSpaceA ~= internalSpaceB)

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
