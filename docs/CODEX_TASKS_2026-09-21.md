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
- l'iterazione deve essere deterministica per Quest ID crescente;
- il callback non deve poter modificare i record reali del registry: passare una copia o equivalente sicuro;
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

## Task 4 — Collector per traduzioni parziali

**DA PASSARE A CODEX DOMANI**

Specifica obbligatoria:

`docs/COLLECTOR_FORMAT.md` → sezione `Traduzioni parziali`.

Obiettivo:

- aggiungere bucket `incomplete`;
- reason `translation_field_missing`;
- se una traduzione esiste ma manca il campo sorgente osservato, raccogliere soltanto quel campo mancante;
- precedenza: missing → incomplete → modified → verifyClassic;
- un `modified` non deve sparire perché un evento successivo, relativo a un altro campo, risulta uguale;
- rivalutare il contenuto già raccolto prima di cancellare un `modified`;
- analogamente, un record `incomplete` non deve sparire a causa di un evento non collegato al campo mancante;
- rimuovere il Quest ID da `incomplete` quando non serve più;
- inizializzare il nuovo bucket in modo retrocompatibile senza cancellare gli altri SavedVariables;
- aggiornare test/diagnostica senza messaggi automatici in chat.

Stato dopo implementazione:

**DA TESTARE SU CLASSIC**

## Task 5 — Stati traduzione nel validator

**DA PASSARE A CODEX DOMANI**

Specifica obbligatoria:

`docs/TRANSLATION_STYLE.md` → `Stati traduzione v0.1`.

La correzione delle label UI è già stata applicata manualmente il 20 settembre ed è **DA TESTARE**.

Obiettivo Codex:

- far conoscere al validator gli stati `draft`, `reviewed`, `verified_classic`, `verified_forever`;
- accettare temporaneamente `manual_test_translation` come stato legacy con warning;
- rifiutare stati sconosciuti nei record reali;
- non cambiare nuovamente la UI se non emerge un errore specifico durante la review.

## Task 6 — Privacy scrubber: evitare sostituzioni dentro parole

**DA PASSARE A CODEX DOMANI**

Problema individuato nello static review:

`Privacy:SanitizeText()` oggi sostituisce il nome del personaggio come semplice sottostringa.

Esempio teorico:

`Ash` potrebbe alterare `Ashenvale`.

Obiettivo:

- continuare a sostituire il nome reale con `<PLAYER>`;
- sostituire soltanto occorrenze del nome come token/nome completo, non dentro parole più lunghe;
- preservare casi con punteggiatura o possessivo;
- non salvare mai il nome reale;
- aggiungere self-test sintetici;
- nessuna nuova API WoW.

Stato dopo implementazione:

**DA TESTARE SU CLASSIC**

## Task 7 — Importer JSON → Lua

**DA PASSARE A CODEX DOMANI, DOPO I TASK 1-6**

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

## Già sistemato il 20 settembre

Non ripetere questi lavori domani:

- resolver fail-closed su flavor sconosciuto;
- rifiuto Quest ID duplicati nello stesso layer;
- collector fermo su flavor client non riconosciuto;
- mapID passato attraverso il controllo plain/secret value;
- label UI Forever basata su `_meta.status`;
- metadata TOC `X-License: MIT`.

Queste modifiche sono **DA TESTARE SU CLASSIC** dove applicabile.

## Ordine consigliato

```text
PRIMA ONDATA
1. datatest
2. normalizzazione hash
3. merge sourceHashes
4. collector incomplete

SECONDA ONDATA
5. stati traduzione nel validator
6. privacy boundary
7. importer

poi review ChatGPT
e test batch Classic quando utile
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
