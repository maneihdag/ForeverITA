# Architettura ForeverITA

## Obiettivo

ForeverITA resta un addon destinato a **WoW Forever**.

WoW Classic Era viene usato soltanto come banco di prova temporaneo per:

- caricamento addon;
- Lua;
- file .toc;
- SavedVariables;
- UI di base;
- eventi quest;
- collector;
- motore dati.

Un test riuscito su Classic **non prova** che la stessa cosa funzioni su Forever.

## Struttura

```text
ForeverITA/
├── Core.lua
├── Compat/
│   ├── API.lua
│   ├── Client.lua
│   ├── Privacy.lua
│   ├── Storage.lua
│   ├── Quest.lua
│   ├── UI.lua
│   └── TranslationUI.lua
├── Core/
│   ├── DataRegistry.lua
│   └── RecordFormat.lua
├── Modules/
│   ├── MissingQuestCollector.lua
│   ├── QuestTranslation.lua
│   └── QuestDebug.lua
├── Data/
│   ├── Classic_it/
│   │   ├── Quests.lua
│   │   └── Mulgore.lua
│   └── Forever_it/
│       └── Quests.lua
└── Dev/
    ├── SelfTest.lua
    └── ClassicSmokeTest.lua
```

## A cosa serve Compat

Tutto ciò che parla direttamente con il client WoW e potrebbe cambiare tra Classic e Forever deve stare in `Compat/`.

Esempi:

- riconoscere il client;
- chiamare API WoW;
- leggere gli eventi quest;
- usare SavedVariables;
- creare UI.

Il resto dell'addon non deve sapere come Classic o Forever implementano queste cose.

## Dati

Su Classic:

```text
Classic_it
   ↓
traduzione
```

Su Forever:

```text
Forever_it
   ↓ se presente
Classic_it
   ↓ fallback
missing
```

Una traduzione Classic usata come fallback su Forever resta **da verificare**.

## Collector

Il collector lavora in background senza messaggi automatici in chat.

Mantiene tre gruppi:

- `missing`: quest senza traduzione;
- `verifyClassic`: quest Forever che stanno usando solo dati Classic e devono essere confrontate;
- `modified`: quest conosciute il cui testo osservato non corrisponde più all'hash sorgente disponibile.

Quando le API lo permettono può raccogliere:

- QuestID;
- titolo;
- descrizione;
- obiettivi;
- progress;
- completion/reward text;
- zona/map ID;
- build/versione client;
- versione addon;
- schema record;
- content hash.

Il collector non salva nome personaggio, account/BattleTag, chat, inventario o lista amici.

La logica di sincronizzazione Internet non appartiene all'addon WoW. Un eventuale Companion futuro resta separato e opzionale.

## Test Classic

Classic Era è il nostro laboratorio temporaneo.

Possiamo segnare come **TESTATO SU CLASSIC**:

- addon caricato;
- Lua senza errori;
- SavedVariables;
- finestra UI;
- eventi quest;
- collector.

Non possiamo trasformare automaticamente quel risultato in **compatibile Forever**.

Le API e il comportamento Forever restano **DA TESTARE SU FOREVER**.

## Fixture

Gli ID `990000001` e `990000002` sono test sintetici interni.

Non sono quest Blizzard.

Servono solo per provare il sistema Classic -> Forever override.


## Confine tecnico del progetto

La cartella `Compat/` non è un ponte verso strumenti esterni: serve soltanto a isolare differenze tra API addon ufficialmente esposte dai vari client WoW.

ForeverITA deve funzionare esclusivamente come addon installato in `Interface/AddOns/ForeverITA`.

Nessun modulo può richiedere:

- DLL;
- programmi residenti esterni;
- injection;
- accesso alla memoria di WoW;
- modifica dei file del client;
- automazione del gameplay.

Se una funzione non è ottenibile tramite le API addon disponibili, viene marcata come **non disponibile / da verificare**, non aggirata con strumenti esterni.

## Perimetro della prima Alpha

Il perimetro preciso della v0.1 è fissato in `docs/V0_1_SCOPE.md`.

Per la prima Alpha la priorità è il ciclo quest:

```text
evento quest
→ Compat/Quest
→ DataRegistry
→ QuestTranslation
→ TranslationUI
```

In parallelo:

```text
evento quest
→ Compat/Quest
→ MissingQuestCollector
→ SavedVariables
```

La traduzione e la raccolta condividono la lettura Compat ma restano moduli separati.
