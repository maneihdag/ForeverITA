local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" or not FIT.Data then
    return
end

-- Traduzioni Classic raccolte e preparate durante il prototipo ForeverITA.
-- Fonte test: WoW Classic Era 1.15.9, build 69722.
-- Forever resta da verificare separatamente.

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
        provenance = "ForeverITA collector SavedVariables, Classic Era test in Mulgore",
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
        provenance = "ForeverITA collector SavedVariables, Classic Era test in Mulgore",
        terminologyNote = "Picco del Tuono verificato; gli altri nomi propri restano in inglese finché non verificati.",
    },
})


-- Terza quest reale di prova.
FIT.Data:RegisterQuest("classic", 750, {
    title = "La caccia continua",

    description = [[Un tauren esperto nell'arte della caccia sa che la sua preda non serve soltanto come trofeo. Le bestie delle pianure ci offrono ciò che ci serve per sopravvivere. Farai una buona impressione sugli anziani se riuscirai a riportare alcune pregiate Mountain Cougar Pelts. Puoi trovare queste bestie aggirarsi sulle colline a sud.

I nostri bambini hanno bisogno di vestiti e le nostre tende devono essere riparate.]],

    objectives = "Grull Hawkwind a Camp Narache vuole che tu gli porti 10 Mountain Cougar Pelts.",

    _sourceHashes = {
        title = "f2-915779862",
        description = "f2-931175005",
        objectives = "f2-425273098",
    },

    _meta = {
        synthetic = false,
        status = "manual_test_translation",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
        provenance = "ForeverITA collector SavedVariables, Classic Era test in Mulgore",
        terminologyNote = "Nomi propri e nome oggetto lasciati in inglese finché non verificati.",
    },
})

-- Quarta quest reale di prova.
-- Include dettaglio, progress e completion per esercitare tutte le fasi della UI.
FIT.Data:RegisterQuest("classic", 3093, {
    title = "Nota incisa con rune",

    description = [[Poco fa un messaggero ti stava cercando, <PLAYER>. Credo che sia stato inviato dall'istruttrice degli sciamani Meela. Se questa nota viene da Meela, non perderei tempo prima di leggerne il contenuto.]],

    objectives = "Leggi la Nota incisa con rune e parla con Meela Dawnstrider a Camp Narache.",

    progress = [[Sei arrivato da me con la stessa rapidità con cui l'acqua cade dal cielo. Sono lieta della tua prontezza. Significa che comprendi sia l'importanza del nostro incontro sia quella della tua presenza qui.

Non sono una guida, ma comprendo gli elementi e so parlare con gli spiriti del nostro popolo. Ti insegnerò a fare lo stesso.]],

    completion = [[Ci incontreremo molte volte nei giorni a venire. Spero che ogni volta lascerai la mia compagnia un po' più potente... un po' più preparato. Come la Fiamma Eterna, il tuo spirito arderà luminoso e intenso.

Ora va', <PLAYER>. Mettiti alla prova. Io sarò qui quando avrai bisogno di me.]],

    _sourceHashes = {
        title = "f2-163691353",
        description = "f2-1603757999",
        objectives = "f2-1136235860",
        progress = "f2-257620214",
        completion = "f2-485747249",
    },

    _meta = {
        synthetic = false,
        status = "manual_test_translation",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
        provenance = "ForeverITA collector SavedVariables, Classic Era test in Mulgore",
        terminologyNote = "Nomi propri lasciati in inglese finché non verificati.",
    },
})

