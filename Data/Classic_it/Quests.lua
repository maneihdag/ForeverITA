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


-- Seconda quest reale di prova.
-- Testa la stessa traduzione in fasi diverse: dettaglio e completamento.
FIT.Data:RegisterQuest("classic", 755, {
    title = "Riti della Madre Terra",

    description = [[La tua disponibilità a svolgere un compito umile per i tauren di Narache e il tuo desiderio di imparare sono qualità nobili, <PLAYER>. Credo che un giorno verrai acclamato a Picco del Tuono come uno sciamano di grande valore.

Prima di allora dovrai intraprendere i Riti della Madre Terra, che sono tre.

La prima prova è il Rito della Forza. Raggiungi Seer Graytongue e digli che ti manda Chief Hawkwind.

Troverai la dimora del veggente direttamente a sud di Camp Narache, nascosta tra le colline.]],

    objectives = "Raggiungi Seer Graytongue, che vive sulle colline direttamente a sud di Camp Narache.",

    completion = "Ti manda Chief Hawkwind? Intraprendere i Riti della Madre Terra non è cosa da poco...",

    _sourceHashes = {
        title = "f2-529049881",
        description = "f2-96613098",
        objectives = "f2-338062873",
        completion = "f2-1229479040",
    },

    _meta = {
        synthetic = false,
        status = "manual_test_translation",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
        terminologyNote = "Picco del Tuono verificato; gli altri nomi propri restano in inglese finché non verificati.",
    },
})
