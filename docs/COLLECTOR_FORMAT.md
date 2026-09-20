# Collector locale ForeverITA

Aggiornato: 2026-09-20.

## Scopo

Il collector lavora in background e salva in SavedVariables solo i testi di quest utili ad aggiornare ForeverITA.

Durante il normale gioco non deve mostrare messaggi in chat.

## Cosa raccoglie

Quando disponibile:

- Quest ID;
- titolo originale;
- descrizione;
- obiettivi;
- progress;
- completion/reward text;
- zona e map ID come contesto;
- versione del client;
- versione di ForeverITA;
- versione del formato record;
- hash del contenuto.

## Cosa non raccoglie

- nome del personaggio;
- BattleTag;
- nome account;
- chat;
- inventario;
- lista amici;
- gilda;
- posta;
- altri dati personali non necessari.

## Quando salva un record

Solo se la quest è:

- senza traduzione;
- una traduzione Classic che su Forever deve ancora essere verificata;
- già conosciuta ma con testo originale diverso rispetto all'hash sorgente disponibile.

## Formato

SavedVariables principale:

```text
ForeverITA_CollectorDB
```

Schema database attuale:

```text
schema = 3
recordSchema = 2
```

Esempio concettuale:

```lua
missing = {
    [12345] = {
        schema = 2,
        type = "quest",
        id = 12345,
        reason = "translation_missing",
        content = {
            title = "...",
            description = "...",
            objectives = "...",
            progress = "...",
            completion = "..."
        },
        context = {
            zone = "...",
            mapID = 12
        },
        contentHash = "q2-123456789",
        revision = 1,
        addonVersion = "0.0.2-alpha",
        client = {
            version = "...",
            build = "...",
            interface = 11509,
            flavor = "classic"
        }
    }
}
```

## Hash e deduplicazione

L'hash identifica il contenuto testuale della quest.

Zona e map ID non cambiano l'hash, così la stessa quest incontrata in due posti non viene considerata un nuovo testo.

Se lo stesso Quest ID viene osservato con lo stesso hash:

- non viene creato un nuovo record;
- non aumenta la revisione;
- vengono aggiornati solo i metadati utili.

Se il testo cambia:

- cambia l'hash;
- aumenta `revision`;
- il record diventa utile per una futura sincronizzazione.

## Scrittura su disco

WoW mantiene le SavedVariables in memoria durante la sessione e le scrive su disco quando il client fa logout, esce o esegue `/reload`.

Per questo un futuro Companion esterno non deve tentare di leggere la memoria di WoW: deve osservare soltanto il file SavedVariables dopo che il client lo ha scritto.

## Stato attuale

Il collector locale fa parte della prima fase.

Il Companion e qualunque invio Internet non fanno parte della prima versione.

## Nota sul rilevamento dei testi modificati

Il gruppo `modified` può essere usato quando un record di traduzione contiene hash affidabili dei singoli campi originali (`_sourceHashes`).

Il confronto avviene per campo: title, description, objectives, progress e completion vengono confrontati soltanto quando esiste il relativo hash dentro `_sourceHashes`. Se non abbiamo un hash sorgente affidabile per il campo osservato, ForeverITA non deve inventare che quel campo sia modificato.

## Privacy nei testi personalizzati

Alcune quest possono inserire il nome del personaggio dentro il testo mostrato dal gioco.

Prima di salvare il record, ForeverITA sostituisce gli alias del personaggio ottenuti tramite API addon con il segnaposto:

`<PLAYER>`

Il nome viene usato solo temporaneamente in memoria per la pulizia e non viene scritto nel database collector.

Il record schema 2 conserva inoltre i campi raccolti in eventi diversi della stessa quest: per esempio descrizione/obiettivi letti all'apertura non vengono persi quando più tardi arriva il testo di completion.

## Normalizzazione testo sorgente

**Decisione di progetto — da implementare.**

Prima di calcolare gli hash dei testi sorgente, ForeverITA dovrà usare una forma canonica per evitare falsi `modified` causati soltanto da differenze di formattazione.

Regola prevista:

- convertire `\r\n` e `\r` in `\n`;
- rimuovere solo gli spazi bianchi iniziali e finali dell'intero campo;
- preservare interamente spazi e ritorni a capo interni;
- applicare la stessa normalizzazione sia quando viene creato `_sourceHashes`, sia quando il collector confronta il testo osservato.

Non vanno compattati gli spazi interni e non vanno riscritti i paragrafi: l'obiettivo è eliminare differenze tecniche di newline/bordi, non alterare il contenuto.

Stato: **DA PASSARE A CODEX DOMANI** e poi **DA TESTARE SU CLASSIC**.

## Traduzioni parziali

**Decisione di progetto — da implementare.**

Una quest può esistere nel database ma avere soltanto alcuni campi tradotti. In questo caso non deve essere trattata come completamente coperta.

Esempio:

```text
title ✅
description ✅
objectives ✅
progress ❌
completion ❌
```

Se durante il gioco viene osservato un campo sorgente che non ha il corrispondente campo tradotto, il collector dovrà registrarlo nel bucket:

`incomplete`

con reason:

`translation_field_missing`

Nel bucket `incomplete` devono essere conservati soltanto i campi sorgente osservati che mancano nella traduzione, oltre a ID, contesto, build, hash e metadati già previsti dal formato record.

Precedenza prevista del collector:

```text
nessuna traduzione
→ missing

traduzione presente ma campo osservato non tradotto
→ incomplete

su Forever usa soltanto base Classic
→ verifyClassic

campo sorgente noto con hash diverso
→ modified

altrimenti
→ nessun record
```

Quando la traduzione diventa completa per i campi osservati, il Quest ID deve essere rimosso da `incomplete` al successivo incontro.

L'aggiunta del bucket può essere retrocompatibile: `Compat/Storage.lua` può inizializzarlo quando manca senza cancellare gli altri dati. Non aumentare automaticamente lo schema finché non è necessario per incompatibilità reali.

Stato: **DA PASSARE A CODEX DOMANI** e poi **DA TESTARE SU CLASSIC**.
