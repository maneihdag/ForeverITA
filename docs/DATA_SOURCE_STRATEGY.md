# Strategia sorgenti dati ForeverITA

Aggiornato: 2026-09-20.

## Obiettivo

Far crescere il database senza copiare alla cieca grandi quantità di testo e senza confondere licenza del codice, provenienza dei dati e diritti sui contenuti World of Warcraft.

## Ordine di preferenza

### 1. Testo osservato direttamente dal collector ForeverITA

È la sorgente tecnica preferita per capire cosa mostra realmente il client.

Il collector può fornire:

- Quest ID;
- titolo;
- descrizione;
- obiettivi;
- progress;
- completion;
- build e contesto;
- hash dei campi.

Il testo raccolto serve come sorgente da tradurre e come riferimento per rilevare modifiche.

### 2. Terminologia italiana ufficiale verificabile

Usare fonti Blizzard italiane quando disponibili per:

- nomi di zone;
- nomi di fazioni;
- nomi di luoghi;
- terminologia ricorrente;
- formule consolidate.

Non assumere che esista una traduzione ufficiale italiana per ogni quest Vanilla.

### 3. Traduzione originale ForeverITA

Per testi senza fonte italiana riutilizzabile:

- traduzione manuale o assistita;
- revisione terminologica;
- placeholder `<PLAYER>`;
- metadati di provenienza;
- hash del testo sorgente osservato.

Questa è la strada preferita per nuove quest Forever.

### 4. Database e addon di terze parti

Possono essere usati per studio, confronto e controllo terminologico soltanto dopo verifica della licenza e della provenienza.

Non importare automaticamente dati soltanto perché un repository è pubblico.

## Sorgenti studiate

### Daribon/QuestTranslator

Contiene un grande `QuestData_it.lua` italiano e un addon che mostra le traduzioni in una finestra separata.

Non è presente una licenza repository chiaramente dichiarata.

**Uso ForeverITA:** studio e confronto; nessuna importazione massiva.

### leoaviana/QuestTradutor

Mostra una separazione pratica tra:

- quest;
- gossip;
- tooltip;
- inizializzazione per diversi client.

Non è presente una licenza repository chiaramente dichiarata.

**Uso ForeverITA:** studio architetturale; nessuna copia automatica.

### Questie

È utile soprattutto come riferimento per:

- database strutturati;
- validazione;
- test automatici;
- separazione tra provider dati e consumer.

Il repository non dichiara una singola licenza globale tramite metadata GitHub; esistono licenze specifiche per componenti.

**Uso ForeverITA:** riferimento di progettazione e validation, non sorgente diretta da copiare.

### MangosZero Localisation Project

Il repository contiene effettivamente:

`Translations/Italian/Italian_Quest.sql`

oltre a dati italiani per creature, oggetti, gossip, NPC text e page text.

Il repository non dichiara una licenza chiara nei metadata GitHub.

**Uso ForeverITA:** sorgente da studiare e confrontare, ma importazione bloccata finché licenza/provenienza non vengono chiarite.

### CMaNGOS classic-db

Il repository è GPL-3.0, ma il suo README e `COPYRIGHT.md` distinguono esplicitamente il software dai materiali World of Warcraft protetti da copyright.

**Uso ForeverITA:** struttura, ID e validazione. Non considerare automaticamente i testi di gioco redistribuibili sotto GPL.

## Sorgenti Forever recenti

### ForeverDiffCollector

MIT.

Conferma un approccio:

- event-driven;
- SavedVariables;
- limiti di crescita;
- API quest tradizionali;
- interface 11509 + 16001.

Può essere studiato. ForeverITA mantiene però il proprio collector separato e privacy-minimizzato.

### ForeverTome

GPL-2.0.

Include addon e tooling esterno. Per ForeverITA è utile come riferimento, ma non va introdotto come dipendenza runtime.

### Carbonite Forever/Camelot

GPL-3.0.

Utile per osservare compatibilità reale con la beta e problemi UI. Non è una sorgente da copiare nel core.

### Horizon Suite

MIT.

Utile per capability detection e report di comportamento della beta, inclusa la persistenza SavedVariables.

## Decisione per la v0.1

Non fare una importazione massiva oggi.

Prima servono:

1. validator dati;
2. schema import definito in `docs/IMPORT_FORMAT.md`;
3. fonte autorizzata o traduzione originale ForeverITA;
4. controllo placeholder;
5. controllo hash;
6. test su un piccolo campione.

Il futuro importer è uno strumento di sviluppo, non una dipendenza runtime dell'addon.

Il formato scelto per la v0.1 è JSON batch → Lua deterministico. L'importer non scaricherà fonti e non aggiornerà automaticamente il TOC nella prima versione.
