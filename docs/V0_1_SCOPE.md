# ForeverITA v0.1 Alpha — perimetro tecnico

Aggiornato: 2026-09-20.

## Obiettivo

La v0.1 Alpha deve dimostrare che ForeverITA può funzionare come normale addon WoW per leggere una quest, risolvere la traduzione italiana corretta e mostrarla senza modificare il client.

WoW Forever resta il target finale. WoW Classic Era resta soltanto il banco di prova temporaneo.

## Dentro la v0.1

La prima Alpha comprende:

- rilevamento del client in `Compat/Client.lua`;
- accesso alle API quest tramite `Compat/Quest.lua`;
- protezione dai valori non accessibili tramite `Compat/API.lua`;
- SavedVariables tramite `Compat/Storage.lua`;
- anonimizzazione del nome giocatore tramite `Compat/Privacy.lua`;
- pannello italiano separato dalla UI Blizzard tramite `Compat/TranslationUI.lua`;
- motore dati Classic + override Forever in `Core/DataRegistry.lua`;
- formato record e hash in `Core/RecordFormat.lua`;
- traduzione delle fasi QUEST_DETAIL / QUEST_PROGRESS / QUEST_COMPLETE;
- collector silenzioso delle quest mancanti o da verificare;
- separazione dati `Data/Classic_it` e `Data/Forever_it`;
- fixture e strumenti diagnostici in `Dev/`;
- formato di importazione dati definito in `docs/IMPORT_FORMAT.md`;
- test differiti raccolti in `docs/DEFERRED_TESTS.md`.

## Fuori dalla v0.1

Non sono requisiti della prima Alpha:

- Companion;
- upload Internet;
- gossip/NPC generico;
- tooltip;
- traduzione oggetti;
- traduzione spell;
- traduzione completa della UI;
- automazione gameplay;
- modifica diretta del client;
- importazione massiva da fonti con licenza o provenienza non chiarite.

Queste funzioni possono essere studiate, ma non devono rallentare la prima Alpha.

## Strati

```text
WoW client
   ↓
Compat/
   ↓
Core/
   ↓
Modules/
   ↓
Data/Classic_it
   ↓ fallback su Forever
Data/Forever_it
```

### Compat

Unico punto che conosce le differenze tra client.

Contiene API, eventi, SavedVariables, privacy e UI che possono cambiare tra Classic e Forever.

### Core

Non deve dipendere da dettagli specifici della UI di un client.

Gestisce:

- risoluzione dati;
- merge Classic/Forever;
- formato record;
- hash.

### Modules

Usano Core e Compat per implementare funzioni:

- visualizzazione traduzione;
- collector;
- diagnostica.

### Data

`Classic_it` contiene la base.

`Forever_it` contiene soltanto:

- override di campi modificati;
- record Forever-only;
- eventuali record rimossi tramite modalità esplicita.

## Regola Forever

Su Forever:

```text
Forever override
      ↓ se manca un campo
Classic base
      ↓ se manca anche lì
missing
```

Una traduzione Classic mostrata su Forever resta da verificare fino al confronto reale con il client Forever.

## Stato minimo per dichiarare v0.1 Alpha

Prima della release Alpha servono:

1. nessun errore Lua nel batch di test;
2. validator dei dati traduzione;
3. normalizzazione canonica del testo prima degli hash;
4. test del collector su Classic;
5. test della UI traduzione su Classic;
6. almeno un test reale su Forever per caricamento, API quest, UI e SavedVariables;
7. documentazione chiara su ciò che è verificato e ciò che non lo è;
8. nessuna dipendenza runtime esterna.

## Stato attuale

Già testato su Classic:

- caricamento addon;
- SavedVariables;
- collector;
- privacy collector;
- UI traduzione iniziale;
- apertura/chiusura automatica;
- prima quest tradotta.

Ancora da testare in batch su Classic:

- UI per fase;
- dataset Mulgore completo attuale;
- hash per campo;
- pulizia bucket collector;
- modifiche recenti elencate in `DEFERRED_TESTS.md`.

Tutto ciò che dipende dal client reale Forever resta **DA TESTARE SU FOREVER**.
