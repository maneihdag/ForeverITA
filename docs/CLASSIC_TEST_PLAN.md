# Piano di test su WoW Classic Era

Classic Era viene usato solo come ambiente di sviluppo temporaneo.

Versione verificata online al 20 settembre 2026:

- WoW Classic Era: 1.15.9
- Interface: 11509

## Installazione

Mettere la cartella `ForeverITA` qui:

```text
World of Warcraft/
└── _classic_era_/
    └── Interface/
        └── AddOns/
            └── ForeverITA/
                └── ForeverITA.toc
```

## Test da fare nell'ordine

### 1. Caricamento

Entrare in gioco e verificare che compaia:

```text
[ForeverITA] Addon caricato. Versione 0.0.2-alpha
```

Poi:

```text
/fit status
```

Il client deve essere riconosciuto come `classic`.

### 2. Motore dati

Usare:

```text
/fit selftest
```

Obiettivo: tutti i test PASS.

Le quest usate qui sono sintetiche, non contenuti Blizzard.

### 3. UI

Usare:

```text
/fit ui
```

Deve comparire una piccola finestra ForeverITA.

Questo prova solo la UI di base su Classic.

### 4. SavedVariables

Usare:

```text
/fit svtest start
/reload
/fit svtest check
```

Obiettivo su Classic: PASS.

### 5. Quest reali Vanilla

Aprire normalmente 2 o 3 quest disponibili sul personaggio.

ForeverITA deve stampare in chat almeno:

- evento;
- QuestID;
- titolo;
- descrizione/obiettivi quando disponibili;
- progress quando si parla con un NPC durante una quest;
- completion quando si consegna una quest.

Non serve cercare quest specifiche: usiamo quelle che il personaggio incontra normalmente.

### 6. Collector

Dopo aver aperto alcune quest:

```text
/fit collector
```

Il numero `missing` dovrebbe aumentare per le quest che non sono ancora nel database italiano.

### 7. Controllo generale

Usare:

```text
/fit classictest
```

Questo riepiloga cosa ha già funzionato.

## Come leggiamo i risultati

- Funziona su Classic -> **TESTATO SU CLASSIC**
- Non provato sulla beta -> **DA TESTARE SU FOREVER**
- Funziona su Classic e Forever -> solo allora può diventare **VERIFICATO SU FOREVER**

Classic non è usato per decidere che una quest Vanilla sia identica in Forever.
