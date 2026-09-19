local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" or not FIT.Data then
    return
end

-- Fixture sintetica: NON è una quest Blizzard e non è contenuto di gioco.
-- Serve solo a verificare il resolver Classic -> Forever senza importare dati esterni.
FIT.Data:RegisterQuest("classic", 990000001, {
    title = "[TEST] Base Classic",
    description = "Record sintetico usato per testare il livello dati Classic.",
    objectives = "Verifica il fallback dei campi non sovrascritti.",
    _meta = {
        synthetic = true,
        provenance = "ForeverITA internal test fixture",
    },
})


-- Prima quest reale di prova.
-- Traduzione manuale ForeverITA basata sul testo osservato su WoW Classic Era 1.15.9.
-- I nomi propri non verificati in italiano vengono lasciati in inglese.
FIT.Data:RegisterQuest("classic", 757, {
    title = "Rito della Forza",

    description = [[I Riti della Madre Terra sono le prove che un giovane tauren deve affrontare per guadagnarsi il rispetto di Picco del Tuono.

Per prima cosa devi superare il Rito della Forza. In questa prova dovrai dimostrare il tuo coraggio abbattendo i nemici della tribù.

I Bristleback della Brambleblade Ravine, a est, stanno invadendo le terre della nostra tribù. Tendono imboscate ai nostri gruppi di cacciatori e, col favore delle tenebre, rubano al villaggio.

Dimostra il tuo valore eliminando questi nemici e torna da Chief Hawkwind a Camp Narache con le loro cinture come prova delle tue gesta.]],

    objectives = "Uccidi i Bristleback nella Brambleblade Ravine e porta 12 Bristleback Belts a Chief Hawkwind a Camp Narache.",

    _sourceHashes = {
        title = "f2-583207982",
        description = "f2-1605805047",
        objectives = "f2-41009017",
    },

    _meta = {
        synthetic = false,
        status = "manual_test_translation",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
        terminologyNote = "Picco del Tuono verificato; altri nomi propri lasciati in inglese finché non verificati.",
    },
})
