# Piano Codex — 2026-09-21

Preparato: 2026-09-20.

Branch:

`architecture-v0.0.2`

Non lavorare su `main` e non fare merge.

## Cambio di piano

Il 20 settembre lo sviluppo è proseguito manualmente con ChatGPT + GitHub mentre Codex non era disponibile.

Le modifiche che inizialmente erano previste per Codex sono già state implementate, ma NON sono ancora considerate verificate.

Domani Codex Sol medio va usato soprattutto come reviewer/esecutore di correzioni, non per riscrivere l'architettura.

## Già implementato il 20 settembre

- `Dev/TranslationDataValidator.lua`;
- `/fit datatest`;
- `Data:ForEachQuest()` deterministico e con copie dei record;
- fail-closed sui flavor sconosciuti;
- rifiuto Quest ID duplicati nello stesso layer;
- hash canonicalizzati con `RecordFormat.schema = 3`;
- SavedVariables DB schema 4 / record schema 3;
- hash reali Mulgore migrati a f3;
- merge `_sourceHashes` e `_dynamicFields` negli override Forever;
- rimozione dei metadata Classic obsoleti dai campi testuali sovrascritti da Forever;
- bucket collector `incomplete`;
- persistenza dell'evidenza `modified`/`incomplete` tra eventi;
- comparator conservativo sui campi dinamici;
- privacy scrubber con confini, evitando sostituzioni dentro parole più lunghe;
- label UI Forever basata su `_meta.status`;
- importer `tools/import_quests.py`;
- fixture JSON sintetiche;
- test offline `tools/test_import_quests.py`.

Tutto questo resta **DA REVISIONARE** e, dove applicabile, **DA TESTARE SU CLASSIC**.

## Task 1 — Review statica del runtime Lua

**PRIORITÀ MASSIMA**

Leggere prima:

- `AGENTS.md`;
- `docs/V0_1_SCOPE.md`;
- `docs/AUDIT_2026-09-20.md`;
- `docs/COLLECTOR_FORMAT.md`;
- `docs/TRANSLATION_STYLE.md`.

Poi revisionare senza grandi riscritture:

- `Core/DataRegistry.lua`;
- `Core/RecordFormat.lua`;
- `Compat/Storage.lua`;
- `Compat/Privacy.lua`;
- `Compat/Quest.lua`;
- `Compat/TranslationUI.lua`;
- `Modules/MissingQuestCollector.lua`;
- `Modules/QuestTranslation.lua`;
- `Dev/SelfTest.lua`;
- `Dev/TranslationDataValidator.lua`;
- `Core.lua`;
- `ForeverITA.toc`.

Controllare in particolare:

- sintassi Lua compatibile con WoW;
- nessuna API inventata;
- nessuna regressione nel fallback Classic/Forever;
- `_mode = replace/remove` invariati;
- merge metadata per campo corretto;
- override metadata-only `verified_forever` risolto tramite fallback Classic senza duplicare la traduzione;
- nessun `modified` perso per un evento successivo non correlato;
- nessun `incomplete` perso per un evento successivo non correlato;
- caso simultaneo `modified` + `incomplete`: `modified` deve avere precedenza senza perdere stabilità tra eventi;
- campi dinamici esclusi dal confronto hash;
- nessun dato personale aggiuntivo;
- privacy con punteggiatura UTF-8/possessivi e nessuna sostituzione dentro parole più lunghe;
- nessun output automatico in chat del collector;
- schema 3/f3/q3 coerente ovunque;
- `fieldHashes` presenti e coerenti nei nuovi record collector;
- DB schema 4 coerente.

Se trovi un errore, applica una correzione piccola e aggiungi/aggiorna un test logico quando possibile.

Non cambiare architettura solo per preferenza personale.

## Task 2 — Review e test dell'importer

File:

- `tools/import_quests.py`;
- `tools/test_import_quests.py`;
- `tools/fixtures/import_classic_sample.json`;
- `tools/fixtures/import_forever_sample.json`;
- `docs/IMPORT_FORMAT.md`.

Eseguire almeno:

```text
python tools/import_quests.py tools/fixtures/import_classic_sample.json --check
python tools/import_quests.py tools/fixtures/import_forever_sample.json --check
python tools/test_import_quests.py
```

Poi generare output temporanei e verificare:

- determinismo;
- ordine Quest ID;
- escaping;
- `merge` senza `_mode`;
- `replace` e `remove` corretti;
- dynamicFields;
- status `verified_classic`/`verified_forever` coerenti con il layer e con sourceClient/sourceBuild;
- override Forever metadata-only e dynamic metadata ereditato dalla base Classic;
- rifiuto duplicati;
- rifiuto hash f2;
- nessuna modifica automatica al TOC.

Non importare dati reali da repository esterni in questo task.

## Task 3 — Review del dataset Mulgore

Controllare soltanto struttura e coerenza tecnica dei record:

- Quest 750;
- Quest 755;
- Quest 757;
- Quest 3093.

Non riscrivere le traduzioni per gusto stilistico.

Verificare:

- hash f3 presenti per i campi tradotti;
- `_dynamicFields` della Quest 755;
- provenance;
- status legacy gestito come warning dal validator.

## Commit

Se servono correzioni:

- commit piccoli;
- un problema per commit quando ragionevole;
- messaggi chiari;
- niente merge su main.

Se non trovi errori in un'area, non modificarla.

## Riepilogo finale richiesto a Codex

Alla fine riportare:

1. controlli eseguiti;
2. problemi trovati;
3. file modificati;
4. test eseguiti e risultati;
5. cose ancora DA TESTARE SU CLASSIC;
6. cose ancora DA TESTARE SU FOREVER;
7. eventuali decisioni che richiedono ChatGPT invece di essere prese autonomamente.

## Fuori scope

Non implementare:

- Companion;
- upload Internet;
- gossip;
- tooltip;
- oggetti/spell;
- nuove dipendenze;
- scraping;
- import CMaNGOS/Daribon;
- API Forever ipotetiche;
- grandi riscritture UI;
- automazione gameplay;
- merge su main.
