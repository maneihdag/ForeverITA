# Task Codex — 2026-09-21

Preparato: 2026-09-20.

Questi task sono ordinati per priorità e devono essere eseguiti in commit separati e piccoli sul branch `architecture-v0.0.2`.

Non fare merge su `main`.

## Task 1 — Translation Data Validator

**DA PASSARE A CODEX DOMANI**

Obiettivo:

- aggiungere `/fit datatest`;
- aggiungere `Dev/TranslationDataValidator.lua`;
- aggiungere un metodo read-only per iterare le quest nel DataRegistry;
- validare struttura, Quest ID, campi testuali, hash, meta e modalità override;
- nessuna esecuzione automatica;
- nessuna nuova API WoW.

Stato dopo implementazione:

**DA TESTARE SU CLASSIC**

## Task 2 — Normalizzazione canonica degli hash

**DA PASSARE A CODEX DOMANI**

Obiettivo:

- aggiungere a `Core/RecordFormat.lua` una normalizzazione unica del testo usata dagli hash;
- convertire CRLF e CR in LF;
- togliere solo whitespace iniziale/finale del campo;
- non modificare whitespace interno;
- usare la stessa normalizzazione per hash record e hash per campo;
- aggiungere self-test specifici.

Non cambiare il testo memorizzato o mostrato: la normalizzazione serve agli hash.

Stato dopo implementazione:

**DA TESTARE SU CLASSIC**

## Task 3 — Merge `_sourceHashes` negli override Forever

**DA PASSARE A CODEX DOMANI**

Problema individuato nello static review:

`DataRegistry:ResolveQuest()` esegue un merge superficiale.

Se un override Forever parziale definisce soltanto:

```lua
_sourceHashes = {
    title = "..."
}
```

sostituisce l'intera tabella `_sourceHashes` Classic e si perdono gli hash degli altri campi.

Obiettivo:

- durante un normale override Forever, fare merge per campo di `_sourceHashes`;
- gli hash Forever devono prevalere solo sulle chiavi fornite;
- gli hash Classic dei campi non sovrascritti devono restare disponibili;
- `_mode = replace` deve continuare a sostituire tutto;
- `_mode = remove` non cambia;
- non cambiare genericamente il merge di tutte le nested table;
- aggiungere fixture/self-test specifici.

Stato dopo implementazione:

**DA TESTARE SU CLASSIC**

## Task 4 — Importer JSON → Lua

**DA PASSARE A CODEX DOMANI, DOPO I TASK 1-3**

Specifica obbligatoria:

`docs/IMPORT_FORMAT.md`

Prima versione:

- tool di sviluppo esterno all'addon;
- Python standard library soltanto;
- nessuna dipendenza;
- nessun download Internet;
- input JSON schema 1;
- modalità check;
- output Lua deterministico;
- quest ordinate per ID;
- escaping sicuro;
- non modificare automaticamente il TOC;
- non importare repository esterni;
- non tradurre automaticamente.

Il tool deve poter essere testato con fixture sintetiche create apposta, senza copiare dati Blizzard o repository esterni.

## Ordine consigliato

```text
1. datatest
2. normalizzazione hash
3. merge sourceHashes
4. importer
5. review ChatGPT
6. test batch Classic quando utile
```

## Fuori scope

Non affidare a Codex domani:

- Companion;
- gossip;
- tooltip;
- grandi riscritture UI;
- API Forever inventate;
- import CMaNGOS/Daribon;
- scraping;
- nuove dipendenze;
- merge su main.
