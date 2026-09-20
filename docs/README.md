# ForeverITA — indice documentazione

Aggiornato: 2026-09-20.

Questo file serve a evitare che la cartella `docs/` diventi disordinata.

## Per iniziare

- `V0_1_SCOPE.md` — cosa entra nella prima Alpha e cosa resta fuori;
- `ARCHITECTURE.md` — struttura tecnica del progetto;
- `AUDIT_2026-09-20.md` — problemi individuati e stato delle correzioni;
- `CODEX_TASKS_2026-09-21.md` — piano operativo per la prossima sessione Codex.

## Dati e traduzioni

- `TRANSLATION_STYLE.md` — stile, terminologia, status e placeholder;
- `GLOSSARY_IT.md` — glossario italiano verificato/provvisorio;
- `DATA_SOURCE_STRATEGY.md` — regole sulle sorgenti dati;
- `IMPORT_FORMAT.md` — formato JSON → Lua dell'importer;
- `COLLECTOR_FORMAT.md` — formato e classificazione del collector.

## Test

- `V0_1_TEST_PLAN.md` — piano batch per la v0.1;
- `CLASSIC_TEST_PLAN.md` — piano test Classic;
- `CLASSIC_TEST_RESULTS.md` — risultati realmente ottenuti;
- `DEFERRED_TESTS.md` — controlli accumulati da eseguire insieme;
- `FIRST_TRANSLATION_TEST.md` — storico del primo test traduzione.

## Ricerca e compatibilità

- `RESEARCH_2026-09-20.md` — ricerca tecnica aggiornata su Forever/API/repository;
- `BLIZZARD_COMPLIANCE.md` — perimetro addon e regole tecniche;
- `PRIVACY.md` — dati raccolti e dati esclusi;
- `LICENSING.md` — licenza del codice e limiti sui contenuti di gioco;
- `THIRD_PARTY.md` è nella radice del repository e raccoglie licenze/provenienza dei riferimenti esterni.

## Futuro

- `COMPANION_DESIGN.md` — progetto del Companion opzionale, NON implementato ora;
- `DOWNLOAD_PAGE_REQUIREMENTS.md` — requisiti futuri della pagina download/privacy.

## Regola operativa

Un documento che descrive una funzione come implementata non equivale a un test riuscito.

Usare sempre le etichette:

- **TESTATO SU CLASSIC**;
- **DA TESTARE SU CLASSIC**;
- **DA TESTARE SU FOREVER**;
- **VERIFICATO SU FOREVER** solo dopo una prova reale.
