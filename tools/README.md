# ForeverITA development tools

Questa cartella contiene strumenti di sviluppo esterni all'addon WoW.

Non vengono caricati da World of Warcraft e non sono dipendenze runtime.

## Requisiti

- Python 3.9 o superiore;
- sola libreria standard Python;
- nessun accesso alla memoria/processo di WoW;
- nessun download automatico di dati esterni.

## Importer

Validazione soltanto:

```text
python tools/import_quests.py tools/fixtures/import_classic_sample.json --check
python tools/import_quests.py tools/fixtures/import_forever_sample.json --check
```

Generazione:

```text
python tools/import_quests.py input.json --output Data/Classic_it/NomeGruppo.lua
```

Il file di output deve essere esplicito e non può coincidere con l'input JSON.

Il tool non modifica automaticamente `ForeverITA.toc`.

## Test offline

```text
python tools/test_import_quests.py
```

I test usano soltanto fixture sintetiche ForeverITA.

## Specifiche

- formato JSON: `docs/IMPORT_FORMAT.md`;
- workflow completo: `docs/TRANSLATION_WORKFLOW.md`;
- regole del progetto: `AGENTS.md`.

## Regola

Gli strumenti di questa cartella automatizzano lavoro meccanico e validation.

Non devono:

- scegliere autonomamente la traduzione;
- inventare API Forever;
- importare dati da repository esterni senza verifica;
- leggere il processo WoW;
- diventare una dipendenza necessaria per usare l'addon.
