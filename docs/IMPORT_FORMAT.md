# Formato di importazione traduzioni

Aggiornato: 2026-09-20.

## Scopo

Il futuro database di ForeverITA crescerà tramite un tool di sviluppo esterno all'addon.

Flusso:

```text
JSON temporaneo
→ validazione
→ tools/import_quests.py
→ Lua deterministico
→ Data/Classic_it/*.lua oppure Data/Forever_it/*.lua
```

Il JSON non viene letto da World of Warcraft e non è una dipendenza runtime.

## Perché JSON

Per la v0.1 è stato scelto JSON perché:

- è semplice da generare;
- Python lo legge con la libreria standard;
- è facile da validare;
- non richiede librerie aggiuntive;
- separa il formato di lavoro dai file Lua caricati in gioco.

## Schema batch v1

Esempio Classic:

```json
{
  "schema": 1,
  "layer": "classic",
  "group": "Mulgore",
  "defaults": {
    "status": "draft",
    "sourceClient": "Classic Era 1.15.9",
    "sourceBuild": "69722"
  },
  "quests": [
    {
      "id": 757,
      "translation": {
        "title": "Rito della Forza",
        "description": "Testo italiano...",
        "objectives": "Obiettivi italiani..."
      },
      "sourceHashes": {
        "title": "f3-1309580852",
        "description": "f3-517983166",
        "objectives": "f3-1315568635"
      },
      "meta": {
        "terminologyNote": "Nota facoltativa"
      }
    }
  ]
}
```

## Campi del batch

### schema

Obbligatorio.

Per la prima versione il solo valore ammesso è:

`1`

Schema sconosciuti devono essere rifiutati.

### layer

Obbligatorio.

Valori:

- `classic`;
- `forever`.

### group

Obbligatorio.

Serve solo per organizzare il batch e commentare il file generato. Non identifica una quest.

Può contenere soltanto lettere ASCII, numeri, trattino e underscore.

### defaults

Facoltativo.

Campi ammessi:

- `status`;
- `sourceClient`;
- `sourceBuild`.

I valori del singolo record prevalgono sui defaults.

## Record quest

### id

Obbligatorio.

Deve essere un intero positivo.

Due record con lo stesso ID nello stesso batch sono un errore.

### translation

Campi ammessi:

- `title`;
- `description`;
- `objectives`;
- `progress`;
- `completion`.

Ogni campo presente deve essere una stringa non vuota.

Un campo assente significa che la traduzione di quel campo non è fornita.

### sourceHashes

Contiene i fingerprint del testo sorgente originale osservato, non della traduzione italiana.

Quando il record proviene dal collector ForeverITA schema 3, questi valori possono essere copiati dal relativo `fieldHashes` del record raccolto.

Chiavi ammesse:

- `title`;
- `description`;
- `objectives`;
- `progress`;
- `completion`.

Formato attuale:

`f3-<numero>`

L'importer v0.1 accetta soltanto schema hash `f3` per evitare di generare dati misti.

Per un record Classic reale, ogni campo presente in `translation` deve avere il relativo `sourceHashes`.

L'importer non inventa hash mancanti e non calcola hash dalla traduzione italiana.

### dynamicFields

Facoltativo.

Serve quando il client renderizza un campo sorgente in modo dipendente dal personaggio.

Esempio:

```json
"dynamicFields": {
  "description": ["class"]
}
```

Token ammessi nella v0.1:

- `class`;
- `race`.

`player` non viene usato qui: il nome giocatore è gestito separatamente dal privacy layer con `<PLAYER>`.

Nel layer Classic un campo dinamico deve esistere anche in `translation`.

Nel layer Forever, `dynamicFields` può anche riferirsi a un campo tradotto ereditato dalla base Classic. Il validator runtime controlla il record risolto dopo il fallback e segnala il caso in cui quel campo non esista davvero.

L'importer non deve inventare `dynamicFields`; devono derivare da una verifica esplicita.

### meta

Campi ammessi:

- `status`;
- `sourceClient`;
- `sourceBuild`;
- `terminologyNote`;
- `provenance`.

Stati ammessi per nuovi record:

- `draft`;
- `reviewed`;
- `verified_classic`;
- `verified_forever`.

Vincoli:

- `verified_classic` è ammesso soltanto per `layer = classic`;
- `verified_forever` è ammesso soltanto per `layer = forever`;
- `verified_forever` richiede `sourceClient` e `sourceBuild`.

Per un record Classic reale, dopo i defaults devono esistere almeno:

- `status`;
- `sourceClient`;
- `sourceBuild`.

## Override Forever

Nel layer `forever` è ammesso:

`operation`

Valori:

- `merge`;
- `replace`;
- `remove`.

### merge

Default.

Il Lua generato non scrive `_mode`.

I campi Forever forniti prevalgono sulla base Classic.

### replace

Il Lua generato scrive:

`_mode = "replace"`

Il record Forever sostituisce completamente la base Classic.

### remove

Il Lua generato scrive:

`_mode = "remove"`

Un remove non contiene translation, sourceHashes o dynamicFields.

### Override di verifica senza duplicare la traduzione

Se la traduzione Classic è ancora valida su Forever, non è necessario duplicare tutto il testo italiano soltanto per marcarla come verificata.

È ammesso un override Forever senza `translation` quando contiene dati utili, per esempio nuovi `sourceHashes`/`dynamicFields`, oppure quando `meta.status = "verified_forever"` con `sourceClient` e `sourceBuild`.

In questo caso il testo italiano continua a fare fallback dalla base Classic, mentre il record Forever documenta la verifica reale sul client.

## Metadata e fallback Forever

Quando un override Forever modifica un campo testuale, i metadata Classic di quel campo non devono sopravvivere automaticamente.

Esempio: se Forever sovrascrive `description` ma non fornisce `_sourceHashes.description`, il resolver rimuove l'hash Classic di description invece di usarlo come se fosse valido per Forever.

I metadata dei campi Classic non sovrascritti continuano invece a fare fallback.

## Placeholder

Placeholder ForeverITA riservato:

`<PLAYER>`

Non inserire nomi reali di personaggi nei dati di traduzione.

Classe e razza sono descritte tramite `dynamicFields`, non tramite sostituzioni globali di parole.

## Testo sorgente inglese

Il JSON di importazione runtime non richiede il testo inglese completo.

Nel file Lua distribuito sono sufficienti:

- traduzione italiana;
- Quest ID;
- sourceHashes;
- metadata necessari.

Il testo sorgente può restare nei SavedVariables del collector o in file temporanei di sviluppo.

## Output Lua

Esempio:

```lua
FIT.Data:RegisterQuest("classic", 757, {
    title = "...",
    description = "...",
    objectives = "...",

    _sourceHashes = {
        title = "f3-...",
        description = "f3-...",
        objectives = "f3-...",
    },

    _meta = {
        synthetic = false,
        status = "draft",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
    },
})
```

Ordine campi generato:

1. title;
2. description;
3. objectives;
4. progress;
5. completion;
6. `_mode`;
7. `_sourceHashes`;
8. `_dynamicFields`;
9. `_meta`.

## Output deterministico

A parità di input il risultato deve essere identico.

Regole:

- quest ordinate per Quest ID crescente;
- UTF-8;
- newline LF;
- nessun timestamp;
- nessun valore casuale;
- ordine campi stabile.

Questo mantiene piccoli e leggibili i diff Git.

## Escaping Lua

Il tool deve gestire in modo sicuro:

- virgolette;
- backslash;
- newline;
- tab;
- caratteri di controllo;
- UTF-8.

La v0.1 genera stringhe Lua quotate ed escapate; non usa long string costruite con testo non controllato.

## File destinazione

Il file di output è sempre esplicito.

Esempio:

```text
python tools/import_quests.py input.json --output Data/Classic_it/Mulgore.lua
```

Il tool non decide automaticamente la zona e non modifica il TOC.

## Modalità check

```text
python tools/import_quests.py input.json --check
```

Con `--check` viene validato l'input senza scrivere file.

Se la validazione fallisce:

- il file di output non viene scritto;
- il comando termina con errore;
- il messaggio indica il record/campo problematico quando possibile.

## Relazione con `/fit datatest`

Sono due controlli diversi.

### Importer validator

Funziona fuori da WoW e controlla il JSON prima della generazione.

### `/fit datatest`

Funziona dentro l'addon e controlla i record effettivamente caricati nel DataRegistry.

## Duplicati

L'importer rifiuta Quest ID duplicati nello stesso batch.

Il DataRegistry rifiuta inoltre una seconda registrazione dello stesso Quest ID nello stesso layer, intercettando duplicati distribuiti tra file diversi.

Lo stesso Quest ID presente in Classic e Forever è valido: è il normale meccanismo di override.

## Cosa NON fa l'importer

La v0.1 non:

- scarica dati da Internet;
- clona repository;
- traduce automaticamente;
- chiama servizi AI;
- decide terminologia;
- modifica il client WoW;
- legge memoria di WoW;
- legge processi o traffico di rete;
- modifica automaticamente il TOC;
- importa fonti con licenza non verificata;
- introduce dipendenze Python esterne.

## Implementazione

Tool:

`tools/import_quests.py`

Fixture sintetiche:

- `tools/fixtures/import_classic_sample.json`;
- `tools/fixtures/import_forever_sample.json`.

Test offline:

`tools/test_import_quests.py`

Comandi:

```text
python tools/import_quests.py tools/fixtures/import_classic_sample.json --check
python tools/import_quests.py tools/fixtures/import_forever_sample.json --check
python tools/test_import_quests.py
```

Stato:

**IMPLEMENTATO — DA REVISIONARE/TESTARE COME TOOL DI SVILUPPO**
