# Piano di crescita del database quest

Aggiornato: 2026-09-20.

## Obiettivo

Passare dalle quattro quest del prototipo a una copertura utile senza trasformare ForeverITA in una traduzione manuale quest-per-quest ingestibile.

La crescita deve restare controllata, verificabile e separata tra Classic e Forever.

## Principio

Non puntiamo subito a "tutte le quest".

Procediamo per blocchi coerenti:

```text
zona / catena iniziale
↓
25–50 quest circa
↓
glossario
↓
traduzione
↓
validator/importer
↓
datatest
↓
QA campione
↓
blocco successivo
```

Il numero 25–50 è una dimensione operativa, non un limite del formato.

## Fase A — Prima zona pilota

Mulgore resta la prima zona pilota.

Obiettivi:

- consolidare il glossario tauren;
- arrivare a un primo blocco coerente di quest iniziali;
- esercitare DETAIL, PROGRESS e COMPLETE;
- verificare class/race/player token;
- verificare il workflow collector → fieldHashes → JSON → Lua;
- misurare quanto lavoro umano serve realmente per 25–50 quest.

Non espandere contemporaneamente in più zone finché questa pipeline non è stata provata.

## Fase B — Altre zone iniziali

Dopo Mulgore scegliere una zona alla volta.

Criteri utili:

- quest Vanilla/Classic facilmente verificabili;
- catene compatte;
- terminologia riutilizzabile;
- buon valore per testare razze/fazioni diverse;
- contenuti che abbiamo realmente incontrato o per cui abbiamo una sorgente lecita e verificabile.

La scelta della zona non deve dipendere soltanto da quale database esterno contiene più testo.

## Preparazione di ogni batch

Per ogni blocco:

1. fissare i Quest ID;
2. ottenere il testo sorgente da collector o altra fonte autorizzata/verificata;
3. controllare i termini ricorrenti nel glossario;
4. preparare traduzioni inizialmente `draft`;
5. copiare i `fieldHashes` necessari;
6. usare JSON schema 1;
7. eseguire importer `--check`;
8. generare il file Lua;
9. eseguire `/fit datatest`;
10. fare revisione linguistica prima di `reviewed`.

## QA

Non è necessario aprire manualmente ogni singola quest per ogni commit.

Per ogni batch usare tre livelli:

### Controllo automatico

- importer;
- validator;
- hash;
- duplicati;
- metadata;
- placeholder;
- struttura.

### Revisione linguistica

Controllare tutto il testo tradotto del batch:

- coerenza;
- grammatica;
- terminologia;
- nomi propri;
- placeholder.

### Test in gioco a campione

Provare un campione rappresentativo che includa:

- quest con solo DETAIL;
- quest con PROGRESS;
- quest con COMPLETE;
- testo lungo;
- `<PLAYER>`;
- campo dinamico class/race quando presente.

Se un problema è sistemico, correggere il batch prima di continuare.

## Stato dei record

Percorso normale:

```text
draft
→ reviewed
→ verified_classic
```

Per Forever:

```text
Classic reviewed/verified_classic
→ osservazione reale su Forever
→ Forever override se necessario
oppure metadata-only verification
→ verified_forever
```

`verified_forever` non viene assegnato in massa per somiglianza teorica.

## Terminologia

Il glossario viene aggiornato prima o durante ogni batch.

Una volta che un termine Blizzard è verificato, deve essere riutilizzato coerentemente nelle quest successive.

Non dedurre automaticamente:

- nomi NPC;
- nomi oggetto;
- nomi località minori;

da una traduzione generica simile.

## Fonti

Ordine operativo:

1. collector ForeverITA;
2. fonte Blizzard italiana per terminologia;
3. traduzione originale ForeverITA;
4. fonti esterne solo per confronto dopo verifica licenza/provenienza.

Nessuna importazione massiva da repository senza licenza chiara.

Il Battle.net Game Data Quest API non fa parte della pipeline v0.1 perché la disponibilità dell'endpoint quest per Classic Era non è stata verificata ed esistono evidenze storiche di 404.

## File dati

Quando il numero di quest cresce, evitare un singolo file enorme.

Organizzazione iniziale consigliata:

```text
Data/Classic_it/
├── Mulgore.lua
├── Elwynn.lua
├── Durotar.lua
└── ...
```

Per Forever:

```text
Data/Forever_it/
├── Mulgore.lua
├── Elwynn.lua
└── ...
```

Creare file Forever soltanto quando esistono override/record specifici reali.

## Criterio per passare alla scala successiva

Prima di superare il primo batch pilota devono essere veri questi punti:

- importer offline testato;
- `/fit datatest` passa;
- selftest passa;
- almeno un batch Classic reale completato senza errori Lua;
- collector produce `fieldHashes` corretti;
- glossario usato in modo coerente;
- processo di revisione non richiede modifiche manuali caotiche nei file Lua.

Se uno di questi punti fallisce, correggere la pipeline prima di aggiungere centinaia di quest.

## Cosa non fare

Per accelerare NON dobbiamo:

- tradurre migliaia di quest alla cieca;
- generare hash da testo non verificato;
- segnare tutto `verified_classic` senza test;
- segnare tutto `verified_forever` senza Forever;
- copiare database italiani con licenza/provenienza dubbia;
- mettere testo sorgente proprietario in grandi quantità nel repository soltanto per comodità;
- aprire più fronti (quest, gossip, tooltip, oggetti) nello stesso momento.

## Traguardo v0.1

La v0.1 non deve essere "WoW tutto tradotto".

Deve dimostrare una pipeline solida:

```text
raccolta
→ traduzione coerente
→ import
→ validation
→ UI
→ verifica
→ override Forever
```

Quando questa pipeline è stabile, aumentare la copertura diventa soprattutto un problema di dati e revisione, non di architettura.
