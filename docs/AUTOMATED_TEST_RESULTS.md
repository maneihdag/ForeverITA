# Test automatici di sviluppo

Aggiornato: 2026-09-20.

## GitHub Actions

Sono attivi due controlli sul branch di sviluppo.

### Development tool tests

Controlla:

- compilazione Python di `tools/import_quests.py` e `tools/test_import_quests.py`;
- validazione fixture Classic;
- validazione fixture Forever;
- suite `tools/test_import_quests.py`.

Risultato verificato il 20 settembre 2026:

**PASS**

Workflow run verificata:

- run `35502758196`;
- job `python-tools` concluso con `success`;
- tutti gli step, inclusi Classic fixture, Forever fixture e importer tests, conclusi con `success`.

### Lua syntax checks

Controlla la sintassi di tutti i file `.lua` con Lua 5.1 (`luac5.1 -p`).

Risultato verificato il 20 settembre 2026:

**PASS**

Le workflow run iniziali sul commit `71dcf68f7066984e5d2f221ee89ea1e5cb118a87` sono concluse con `success`.

Successivamente sono stati aggiunti gli harness Lua offline. Le run successive hanno continuato a passare. La run `35503204060` ha concluso con `success` tutti questi step:

- **Check Lua syntax**;
- **Run offline core/data tests**;
- **Run offline collector tests**;
- **Run offline storage migration tests**.

## Cosa provano

Questi test provano:

- sintassi Lua 5.1 dei file presenti;
- esecuzione offline di `Dev/SelfTest.lua` sui moduli puri caricabili senza WoW;
- esecuzione offline di `Dev/TranslationDataValidator.lua` sull'attuale dataset Classic/Forever;
- classificazione e persistenza logica dei bucket collector;
- migrazione SavedVariables schema 3 → 4 / record schema 2 → 3;
- corretto funzionamento offline dell'importer sulle fixture e sui casi coperti dalla suite;
- assenza di errori Python nei tool testati.

## Cosa NON provano

Non provano:

- caricamento reale dentro WoW;
- disponibilità delle API WoW;
- comportamento degli eventi;
- SavedVariables reali;
- Secret Values;
- compatibilità Forever;
- resa UI.

Quindi i risultati runtime restano separati:

- **DA TESTARE SU CLASSIC** per le modifiche recenti;
- **DA TESTARE SU FOREVER** per tutto ciò che dipende da Forever.
