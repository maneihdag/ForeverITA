# Workflow traduzioni ForeverITA

Aggiornato: 2026-09-20.

## Obiettivo

Ridurre al minimo il lavoro manuale quando una quest viene incontrata e deve entrare nel database italiano.

Questo è il workflow previsto per la v0.1.

## 1. Raccolta in gioco

Il collector intercetta la quest tramite le normali API addon e salva in SavedVariables:

- Quest ID;
- testi sorgente disponibili;
- contesto;
- build/client;
- `contentHash`;
- `fieldHashes` per i singoli campi.

Il collector lavora in silenzio.

## 2. Selezione del record utile

I record vengono classificati in:

- `missing` — nessuna traduzione;
- `modified` — testo sorgente conosciuto ma cambiato;
- `incomplete` — traduzione esistente ma manca un campo osservato;
- `verifyClassic` — base Classic usata su Forever e ancora da verificare.

Non tradurre indiscriminatamente tutto il file SavedVariables.

## 3. Preparazione della traduzione

Per il record scelto:

- mantenere il Quest ID;
- usare il testo sorgente raccolto come riferimento locale di lavoro;
- preparare la traduzione italiana;
- copiare i fingerprint necessari da `fieldHashes` in `sourceHashes`;
- per un campo dichiarato dinamico, ricordare che il `fieldHashes` raccolto rappresenta la variante realmente osservata sul personaggio di test; `_dynamicFields` fa sì che il comparator non lo usi ingenuamente come prova di modifica su altri personaggi;
- usare `<PLAYER>` nei dati, mai il nome reale;
- dichiarare `dynamicFields` soltanto quando il comportamento dinamico è stato verificato.

Il testo inglese completo non deve essere copiato nel database runtime se non serve.

## 4. JSON temporaneo

La traduzione viene preparata nel formato definito da:

`docs/IMPORT_FORMAT.md`

Esempio concettuale:

```text
SavedVariables collector
   ↓
record scelto
   ↓
traduzione italiana + fieldHashes
   ↓
batch JSON temporaneo
```

Il JSON è un file di lavoro, non una dipendenza dell'addon.

## 5. Validazione fuori da WoW

Eseguire:

```text
python tools/import_quests.py input.json --check
```

Il controllo deve passare prima della generazione Lua.

## 6. Generazione Lua

Eseguire:

```text
python tools/import_quests.py input.json --output Data/Classic_it/NomeGruppo.lua
```

oppure nel layer Forever quando si tratta di un override reale.

L'output deve essere deterministico e leggibile nei diff Git.

## 7. TOC

Nella v0.1 l'importer NON modifica automaticamente il TOC.

Se viene creato un nuovo file dati, aggiungerlo esplicitamente a `ForeverITA.toc` nel punto corretto.

## 8. Validator runtime

Dopo che il file è caricato dall'addon:

```text
/fit datatest
```

controlla ciò che il DataRegistry ha realmente ricevuto.

## 9. Test

Non serve provare manualmente ogni singola traduzione appena aggiunta.

Le verifiche vengono accumulate e svolte in batch secondo:

- `docs/DEFERRED_TESTS.md`;
- `docs/V0_1_TEST_PLAN.md`.

## Forever

Una traduzione Classic non diventa automaticamente verificata su Forever.

Su Forever:

```text
Classic base
   ↓
verifica sul client reale
   ↓
eventuale override/metadata Forever
   ↓
verified_forever soltanto dopo test reale
```

Un override metadata-only può essere usato per marcare una traduzione Classic ancora valida su Forever senza duplicare il testo italiano.

## Cosa resta manuale nella v0.1

Per ora restano decisioni umane:

- scelta della quest da tradurre;
- qualità della traduzione;
- terminologia;
- conferma dei campi dinamici;
- passaggio da draft a reviewed/verified;
- decisione di creare un override Forever.

L'automazione serve a ridurre errori e lavoro meccanico, non a inventare dati o compatibilità.
