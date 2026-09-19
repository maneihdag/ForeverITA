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
schema = 2
recordSchema = 1
```

Esempio concettuale:

```lua
missing = {
    [12345] = {
        schema = 1,
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
        contentHash = "q1-123456789",
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

Il gruppo `modified` può essere usato quando un record di traduzione contiene un hash del testo originale noto (`_sourceHash`).

Se non abbiamo ancora un hash sorgente affidabile, ForeverITA non deve inventare che una quest sia modificata: la registra come missing oppure, su Forever quando usa solo la base Classic, come `verifyClassic`.
