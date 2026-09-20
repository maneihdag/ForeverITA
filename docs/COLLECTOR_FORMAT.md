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
schema = 4
recordSchema = 3
```

Esempio concettuale:

```lua
missing = {
    [12345] = {
        schema = 3,
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
        fieldHashes = {
            title = "f3-...",
            description = "f3-...",
            objectives = "f3-..."
        },
        contentHash = "q3-123456789",
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

`contentHash` identifica l'insieme del contenuto testuale della quest.

Il record conserva anche `fieldHashes`, con un fingerprint `f3-*` per ogni campo sorgente osservato. Questi valori possono essere riutilizzati direttamente come `_sourceHashes` quando viene preparata una traduzione, evitando di ricalcolarli manualmente fuori dal collector.

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

Il record schema 3 conserva inoltre i campi raccolti in eventi diversi della stessa quest: per esempio descrizione/obiettivi letti all'apertura non vengono persi quando più tardi arriva il testo di completion.

## Normalizzazione testo sorgente

**IMPLEMENTATO — DA TESTARE SU CLASSIC.**

Prima di calcolare gli hash dei testi sorgente, ForeverITA usa una forma canonica per evitare falsi `modified` causati soltanto da differenze di formattazione.

Regola applicata:

- convertire `\r\n` e `\r` in `\n`;
- rimuovere solo gli spazi bianchi iniziali e finali dell'intero campo;
- preservare interamente spazi e ritorni a capo interni;
- applicare la stessa normalizzazione sia quando viene creato `_sourceHashes`, sia quando il collector confronta il testo osservato.

Non vanno compattati gli spazi interni e non vanno riscritti i paragrafi: l'obiettivo è eliminare differenze tecniche di newline/bordi, non alterare il contenuto.

Stato: **DA TESTARE SU CLASSIC**.

## Traduzioni parziali

**IMPLEMENTATO — DA TESTARE SU CLASSIC.**

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

campo sorgente noto con hash diverso
→ modified

traduzione presente ma campo osservato non tradotto
→ incomplete

su Forever usa soltanto base Classic e i campi osservati non risultano modificati
→ verifyClassic

altrimenti
→ nessun record
```

Se nella stessa osservazione esistono sia un campo mancante sia un campo già tradotto il cui sorgente è cambiato, `modified` ha precedenza. Un cambiamento del sorgente può rendere non valida una traduzione esistente ed è quindi più urgente di un campo semplicemente non ancora tradotto.

Quando la traduzione diventa completa per i campi osservati, il Quest ID deve essere rimosso da `incomplete` al successivo incontro.

L'aggiunta del bucket può essere retrocompatibile: `Compat/Storage.lua` può inizializzarlo quando manca senza cancellare gli altri dati. Non aumentare automaticamente lo schema finché non è necessario per incompatibilità reali.

Stato: **DA TESTARE SU CLASSIC**.

## Persistenza dell'evidenza `modified`

**IMPLEMENTATO — DA TESTARE SU CLASSIC.**

Un record `modified` non deve essere cancellato soltanto perché un evento successivo della stessa quest riguarda un altro campo che coincide con il database.

Esempio:

```text
QUEST_DETAIL
description diversa → modified

QUEST_COMPLETE
completion uguale → NON cancellare il modified della description
```

Il record `modified` può essere rimosso soltanto quando i campi già registrati come evidenza non risultano più diversi rispetto agli `_sourceHashes` correnti, per esempio dopo un aggiornamento del database traduzioni.

L'implementazione può riutilizzare il contenuto già conservato nel record `modified` per rivalutare i campi; non è necessario introdurre un nuovo formato se non serve.

Stato: **DA TESTARE SU CLASSIC**.

### Versionamento della normalizzazione

La normalizzazione cambia il significato dell'hash. Non va quindi introdotta mantenendo lo stesso prefisso `f2/q2`.

Decisione:

- `RecordFormat.schema` è passato da 2 a 3;
- i nuovi fingerprint sono `f3-*`;
- i nuovi content hash sono `q3-*`;
- `Storage.recordSchema` è passato a 3;
- il database SavedVariables è passato da schema 3 a schema 4 per evitare di mescolare record q2 e q3 senza una migrazione esplicita.

Durante questa fase Alpha il cambio schema può inizializzare un nuovo collector DB. I SavedVariables di test importanti già raccolti sono stati archiviati e usati per verificare il primo dataset Mulgore.

Gli `_sourceHashes` dei record Mulgore attuali sono stati ricalcolati con schema 3 nello stesso passaggio che ha introdotto la normalizzazione.

Valori di riferimento già ricontrollati sui sorgenti Classic raccolti:

- Quest 750: title `f3-58031097`, description `f3-1819721703`, objectives `f3-1712647064`;
- Quest 755: title `f3-1993634989`, description `f3-940745371`, objectives `f3-1480327953`, completion `f3-1805373569`; la description è la variante osservata sul personaggio di test e il campo è marcato dinamico `class`;
- Quest 757: title `f3-1309580852`, description `f3-517983166`, objectives `f3-1315568635`;
- Quest 3093: title `f3-1615236429`, description `f3-2076480885`, objectives `f3-2027092750`, progress `f3-2085786229`, completion `f3-528183461`.

La description della Quest 3093 è un buon test perché il sorgente raccolto terminava con CRLF: lo schema 3 deve normalizzarlo prima del fingerprint.

## Campi dinamici e confronto hash

Alcuni campi vengono renderizzati dal client con valori dipendenti dal personaggio.

Caso confermato: Quest 755, description con token classe.

Se il record traduzione dichiara `_dynamicFields[field]`, il comparator non deve usare il singolo `_sourceHashes[field]` per decidere `modified` finché non esiste una canonicalizzazione sicura di quel token.

Questo evita falsi positivi tra personaggi di classi diverse.

Il collector può continuare a conservare il testo effettivamente osservato; ciò che viene sospeso è soltanto la conclusione automatica `source_text_changed` per quel campo.

Non sostituire globalmente parole come `shaman`, `tauren`, `warrior` ecc.: potrebbero essere testo narrativo reale.

## Metadata degli override Forever

Un override Forever parziale eredita dalla base Classic `_sourceHashes` e `_dynamicFields` soltanto per i campi testuali che NON vengono sovrascritti.

Se Forever sovrascrive, per esempio, `description`:

- un nuovo `_sourceHashes.description` viene usato se fornito;
- se non viene fornito, l'hash Classic della description viene rimosso invece di essere riutilizzato in modo ambiguo;
- lo stesso vale per `_dynamicFields.description`.

I metadata dei campi Classic non toccati continuano invece a fare fallback normalmente.

Stato: **IMPLEMENTATO — DA TESTARE SU CLASSIC** con fixture e poi **DA TESTARE SU FOREVER** con dati reali.
