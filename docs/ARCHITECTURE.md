# Architettura ForeverITA

## Principio

ForeverITA non tratta WoW Forever come "Classic con un nome diverso".

Il motore di localizzazione è indipendente dal client; la compatibilità con le API è confinata in adapter piccoli e sostituibili.

## Struttura

```text
ForeverITA/
├── Core.lua
├── Core/
│   ├── Environment.lua
│   ├── DataRegistry.lua
│   └── QuestAPI.lua
├── Modules/
│   ├── QuestDebug.lua
│   └── MissingQuestCollector.lua
├── Data/
│   ├── Classic_it/
│   │   └── Quests.lua
│   └── Forever_it/
│       └── Quests.lua
├── Dev/
│   └── SelfTest.lua
└── docs/
    └── ARCHITECTURE.md
```

## Risoluzione dati

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

L'override Forever è per campo.

Esempio concettuale:

```lua
Classic:
title + description + objectives

Forever override:
description

Risultato Forever:
title       <- Classic
description <- Forever
objectives  <- Classic
```

Un record Forever può usare `_mode = "replace"` quando l'intera quest deve essere considerata separata, oppure `_mode = "remove"` se in futuro serve bloccare esplicitamente un record Classic.

## Regola di verifica

Se su Forever una quest risolve soltanto dal livello Classic, ForeverITA può usarla come fallback futuro, ma il collector la marca come **da verificare su Forever**.

Questo evita di equiparare automaticamente Vanilla e Forever.

## API quest

`Core/QuestAPI.lua` è l'unico punto che legge le API del client per la prima fase.

API candidate attuali:

- `GetQuestID`
- `GetTitleText`
- `GetQuestText`
- `GetObjectiveText`
- `GetProgressText`
- `GetRewardText`

Queste funzioni sono usate da collector Forever pubblici recenti, ma la nostra compatibilità resta **da testare su Forever**.

Ogni chiamata è protetta e l'assenza di una API non deve bloccare l'addon.

## Collector

`ForeverITA_CollectorDB` è una SavedVariable con due gruppi principali:

- `missing`: quest senza traduzione;
- `verifyClassic`: quest che su Forever stanno usando solo il fallback Classic.

Per ogni quest il collector può accumulare, quando disponibili:

- QuestID;
- titolo;
- descrizione;
- obiettivi;
- progress;
- completion;
- NPC GUID/nome;
- build;
- eventi osservati.

Il collector è event-driven e non esegue scansioni continue.

## Fixture

Gli ID `990000001` e `990000002` sono dati sintetici interni.

Servono a testare:

- lookup Classic;
- precedenza Forever;
- merge per campo;
- quest Forever-only;
- record missing.

Non sono quest reali e non devono essere usati come dati di localizzazione.

## Cosa non facciamo ancora

- sostituzione visiva dei testi Blizzard;
- gossip;
- import massivo di quest;
- database reale di migliaia di record;
- assunzioni sulla UI Forever;
- dipendenza diretta dai frame di Classic;
- automazione di upload dei dati raccolti.

Questi punti vengono dopo la validazione del motore e i primi test reali su Forever.
