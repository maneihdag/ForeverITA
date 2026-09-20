# Formato di importazione traduzioni

Aggiornato: 2026-09-20.

## Scopo

Questo documento definisce il formato che userà il futuro importer di sviluppo di ForeverITA.

L'importer NON farà parte dell'addon in gioco.

Flusso previsto:

```text
file JSON temporaneo
        ↓
validator/importer di sviluppo
        ↓
Data/Classic_it/*.lua
oppure
Data/Forever_it/*.lua
        ↓
ForeverITA
```

Il file JSON serve soltanto come formato di scambio per preparare grandi quantità di traduzioni in modo controllato.

Non è una dipendenza runtime.

## Perché JSON

Per la prima versione scegliamo JSON perché:

- è semplice da generare con strumenti automatici;
- supporta testi lunghi e multilinea tramite escaping standard;
- è facile da validare;
- Python può leggerlo con la libreria standard, senza dipendenze esterne;
- non richiede parser dentro WoW.

Non introduciamo YAML o altre librerie.

## Schema batch v1

Esempio:

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
        "title": "f2-583207982",
        "description": "f2-1605805047",
        "objectives": "f2-41009017"
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

Per la prima versione:

`1`

Un importer deve rifiutare schema sconosciuti invece di interpretarli liberamente.

### layer

Obbligatorio.

Valori ammessi:

- `classic`
- `forever`

Determina il livello destinazione di DataRegistry.

### group

Obbligatorio.

Serve soltanto a organizzare i file dati.

Esempi:

- `Mulgore`
- `Elwynn`
- `ForeverIntro`

Deve usare soltanto lettere ASCII, numeri, trattino o underscore.

Non deve essere usato come identità della quest.

L'identità resta sempre il Quest ID.

### defaults

Facoltativo ma raccomandato.

Può fornire valori condivisi dal batch:

- `status`
- `sourceClient`
- `sourceBuild`

Un valore definito nel singolo record può sovrascrivere il default.

## Record quest

Ogni elemento di `quests` contiene:

### id

Obbligatorio.

Deve essere un numero intero positivo.

### translation

Per una quest tradotta contiene soltanto questi campi:

- `title`
- `description`
- `objectives`
- `progress`
- `completion`

Ogni campo presente deve essere una stringa non vuota.

Campi assenti significano "non fornito".

Non usare stringhe vuote per rappresentare campi mancanti.

### sourceHashes

Contiene gli hash dei testi sorgente osservati dal collector.

Chiavi ammesse:

- `title`
- `description`
- `objectives`
- `progress`
- `completion`

Formato:

`^f%d+%-%d+$`

Per i record Classic reali, ogni campo presente in `translation` deve avere il corrispondente hash.

L'importer NON deve inventare hash mancanti.

L'importer NON deve calcolare un hash a partire dalla traduzione italiana.

Gli hash rappresentano il testo sorgente originale, non la traduzione.

### dynamicFields

Facoltativo.

Permette di dichiarare campi sorgente che il client renderizza in modo dipendente dal personaggio.

Esempio:

```json
"dynamicFields": {
  "description": ["class"]
}
```

Valori inizialmente ammessi:

- `class`;
- `race`.

Non usare `player` qui: il nome giocatore è già canonicalizzato come `<PLAYER>` dalla privacy layer.

Un importer non deve inventare dynamicFields. Devono provenire da una verifica esplicita.

### meta

Campi previsti:

- `status`
- `sourceClient`
- `sourceBuild`
- `terminologyNote`
- `provenance`

Per i record reali Classic, dopo aver applicato i valori `defaults`, devono esistere almeno:

- status;
- sourceClient;
- sourceBuild.

`terminologyNote` e `provenance` sono facoltativi.

Le fixture sintetiche interne non passano attraverso questo importer nella v0.1.

## Override Forever

Per `layer = "forever"` è ammesso il campo:

`operation`

Valori:

- `merge`
- `replace`
- `remove`

### merge

È il comportamento predefinito.

Il file Lua generato NON scrive `_mode`.

Solo i campi presenti nell'override sostituiscono quelli Classic.

### replace

Il file Lua generato scrive:

`_mode = "replace"`

Il record Forever sostituisce completamente la base Classic.

### remove

Il file Lua generato scrive:

`_mode = "remove"`

Serve a indicare che la quest non deve essere risolta attraverso la base Classic.

Un record `remove` non richiede una traduzione.

## Placeholder

Nella v0.1 l'unico placeholder ForeverITA riservato è:

`<PLAYER>`

Non inserire nel database nomi reali di personaggi.

L'importer deve poter segnalare come warning eventuali stringhe che sembrano contenere placeholder non riconosciuti, ma non deve inventare conversioni automatiche.

## Testo sorgente inglese

Il formato di importazione NON richiede di salvare il testo inglese originale nel repository.

Per il database runtime sono sufficienti:

- traduzione italiana;
- Quest ID;
- hash del testo sorgente;
- metadati minimi.

Il testo originale può restare nel collector locale o negli strumenti di lavoro temporanei.

## Output Lua

L'importer deve produrre chiamate compatibili con l'architettura attuale:

```lua
FIT.Data:RegisterQuest("classic", 757, {
    title = "...",
    description = "...",
    objectives = "...",

    _sourceHashes = {
        title = "f2-...",
        description = "f2-...",
        objectives = "f2-...",
    },

    _meta = {
        synthetic = false,
        status = "draft",
        sourceClient = "Classic Era 1.15.9",
        sourceBuild = "69722",
    },
})
```

Per Forever cambia soltanto il layer e, quando necessario, viene aggiunto `_mode`.

## Output deterministico

A parità di input, l'importer deve produrre sempre lo stesso file.

Regole:

1. ordinare le quest per Quest ID crescente;
2. ordine campi:
   - title
   - description
   - objectives
   - progress
   - completion
   - _mode
   - _sourceHashes
   - _meta
3. ordine hash uguale all'ordine dei campi testuali;
4. newline del file: LF;
5. UTF-8;
6. nessun timestamp generato dentro i file Lua;
7. nessun dato casuale.

Questo rende i commit leggibili.

## Stringhe Lua

L'importer deve gestire correttamente:

- virgolette;
- backslash;
- ritorni a capo;
- caratteri UTF-8;
- sequenze che potrebbero chiudere una long string Lua.

Non deve concatenare testo non escapato.

La scelta concreta dell'escaping può essere implementata in modo deterministico dal tool.

## File destinazione

Per la v0.1 il comando deve ricevere esplicitamente il file di output.

Esempio futuro:

```text
python tools/import_quests.py input.json --output Data/Classic_it/Mulgore.lua
```

L'importer NON deve scegliere automaticamente dove mettere i dati in base alla zona osservata.

L'importer NON deve modificare automaticamente `ForeverITA.toc` nella prima versione.

Se viene creato un nuovo file dati, l'aggiunta al TOC resta una modifica esplicita e verificabile.

## Modalità check

Il futuro importer deve supportare due modalità concettuali:

```text
--check
```

valida soltanto l'input;

e una modalità di generazione che scrive il file Lua.

Se la validazione fallisce:

- nessun output deve essere sovrascritto;
- il comando deve terminare con errore;
- devono essere indicati Quest ID e campo problematico.

## Relazione con /fit datatest

Sono due controlli diversi.

### Importer validator

Lavora fuori da WoW.

Controlla il JSON prima della generazione.

### /fit datatest

Lavora dentro l'addon.

Controlla ciò che ForeverITA ha realmente caricato nel DataRegistry.

Entrambi sono utili.

## Cosa NON deve fare l'importer

La prima versione non deve:

- scaricare dati da Internet;
- clonare repository esterni;
- tradurre automaticamente;
- chiamare servizi AI;
- decidere da sola la terminologia;
- modificare il client WoW;
- leggere memoria di WoW;
- leggere SavedVariables mentre WoW le tiene soltanto in memoria;
- includere dipendenze Python esterne;
- importare fonti con licenza non verificata.

## Stato

Questo formato è una decisione di progetto.

L'implementazione è:

**DA PASSARE A CODEX DOMANI**

Dopo l'implementazione:

**DA TESTARE COME TOOL DI SVILUPPO**

La parte runtime generata resta inoltre soggetta ai normali test Classic e Forever.

## Duplicati

Il validator/importer deve rifiutare Quest ID duplicati nello stesso batch JSON.

Il runtime DataRegistry deve inoltre rifiutare una seconda registrazione dello stesso Quest ID nello stesso layer, così vengono intercettati anche duplicati distribuiti tra file differenti.

Un Quest ID presente sia in `classic` sia in `forever` NON è un duplicato: è il normale meccanismo di override.
