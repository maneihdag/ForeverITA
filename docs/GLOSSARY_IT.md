# Glossario italiano ForeverITA

Aggiornato: 2026-09-20.

Questo file contiene terminologia verificata, regole conservative e termini ancora aperti.

Non è un elenco completo di World of Warcraft.

## Livelli di affidabilità

Per evitare di confondere una traduzione plausibile con una localizzazione ufficiale, ForeverITA usa tre livelli:

- **Blizzard verificato** — termine trovato in una fonte italiana ufficiale Blizzard;
- **ForeverITA** — scelta di traduzione del progetto, coerente ma non presentata come ufficiale;
- **non verificato** — il termine resta in inglese finché non abbiamo una fonte sufficientemente affidabile.

Le pagine italiane di Wowhead per Classic/Forever possono essere utili per controllare Quest ID e testo sorgente inglese, ma spesso mostrano ancora nomi e testi quest in inglese. Non sono quindi prova sufficiente, da sole, di una localizzazione italiana ufficiale.

## Termini verificati su fonti Blizzard

| Inglese | Italiano | Stato | Nota |
| --- | --- | --- | --- |
| Thunder Bluff | Picco del Tuono | Blizzard verificato | capitale tauren |
| Mulgore | Mulgore | Blizzard verificato | nome invariato |
| Camp Narache | Campo Narache | Blizzard verificato | forma italiana usata in una storia ufficiale Blizzard |
| Bristleback / Bristlebacks | Verrospino | Blizzard verificato | nome della specie/tribù quilboar; non implica automaticamente la traduzione dei nomi oggetto composti |
| Earthmother | Madre Terra | Blizzard verificato | termine religioso tauren |
| Shaman | Sciamano | Blizzard verificato | termine di classe/generico |

Fonti Blizzard:

- https://worldofwarcraft.blizzard.com/it-it/news/10071211/i-segreti-della-localizzazione-italiana-di-world-of-warcraft
- https://worldofwarcraft.blizzard.com/it-it/media/short-story/baine-bloodhoof-as-our-fathers-before-us
- https://worldofwarcraft.blizzard.com/it-it/news/21701414
- https://worldofwarcraft.blizzard.com/it-it/news/23685044

La storia italiana di Baine usa esplicitamente **Campo Narache**, **Verrospino**, **Madre Terra**, **Mulgore** e **Picco del Tuono**.

## Termini ancora non verificati

Per la prima Alpha restano in inglese finché non viene trovata una fonte italiana affidabile:

- Brambleblade Ravine;
- Chief Hawkwind;
- Grull Hawkwind;
- Seer Graytongue;
- Meela Dawnstrider;
- Mountain Cougar Pelt;
- Bristleback Belt.

Importante: il fatto che **Bristleback** sia ufficialmente **Verrospino** non autorizza a inventare automaticamente il nome italiano dell'oggetto **Bristleback Belt**. Finché l'oggetto non viene verificato, il suo nome resta inglese.

## Titoli quest del prototipo

I titoli attuali delle quattro quest Mulgore sono traduzioni ForeverITA, non vengono presentati come titoli Blizzard ufficiali:

- Rite of Strength → **Rito della Forza**;
- Rites of the Earthmother → **Riti della Madre Terra**;
- The Hunt Continues → **La caccia continua**;
- Rune-Inscribed Note → **Nota incisa con rune**.

Dentro **Riti della Madre Terra**, il termine **Madre Terra** è verificato su fonte Blizzard; il titolo completo resta una scelta ForeverITA finché non troviamo una localizzazione ufficiale equivalente.

## Testi dinamici

Il client può sostituire token come classe, razza e nome del personaggio prima che l'addon legga il testo.

Esempi già osservati:

- la Quest 755 usa un token classe nel template, ma il collector ha ricevuto la classe reale del personaggio;
- la Quest 747 usa token razza e nome nel template, ma il collector ha ricevuto i valori già renderizzati.

Non hardcodare nella traduzione il valore visto su un solo personaggio.

Quando possibile, preferire una frase italiana naturale valida per qualunque classe o razza. Il nome del giocatore resta gestito con `<PLAYER>`.

## Regola per nuovi termini

Prima di aggiungere una traduzione stabile al glossario:

1. cercare una fonte Blizzard italiana;
2. se non esiste, cercare una fonte di localizzazione affidabile e documentarne il tipo;
3. se resta dubbio, mantenere il nome inglese;
4. non derivare automaticamente nomi oggetto/NPC da una traduzione generica verificata;
5. documentare la fonte quando il termine diventa una regola stabile.

## Regola per passare a reviewed

Un record `draft` può temporaneamente contenere nomi propri inglesi non ancora verificati.

Prima di passare una traduzione a `reviewed`:

- controllare tutti i termini ricorrenti contro questo glossario;
- sostituire i termini per cui esiste una forma Blizzard verificata;
- lasciare in inglese soltanto termini realmente non verificati o esplicitamente decisi come invarianti;
- aggiornare `terminologyNote` se restano eccezioni.
