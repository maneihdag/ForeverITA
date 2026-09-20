# Audit terminologico Mulgore — 2026-09-20

## Scopo

Controllare i termini ricorrenti nelle prime quattro quest reali di ForeverITA senza inventare localizzazioni.

Quest considerate:

- 750 — The Hunt Continues;
- 755 — Rites of the Earthmother;
- 757 — Rite of Strength;
- 3093 — Rune-Inscribed Note.

## Verificato su Blizzard italiano

| Termine sorgente | Forma ForeverITA | Esito |
| --- | --- | --- |
| Thunder Bluff | Picco del Tuono | confermato |
| Camp Narache | Campo Narache | confermato |
| Earthmother | Madre Terra | confermato |
| Bristleback / Bristlebacks | Verrospino | confermato come specie/tribù |
| Mulgore | Mulgore | confermato invariato |
| Shaman | Sciamano | confermato |

La fonte più utile per il blocco tauren è la storia ufficiale italiana di Baine, che usa nello stesso contesto Mulgore, Campo Narache, Verrospino, Madre Terra e Picco del Tuono.

## Ancora aperto

Non è stata trovata oggi una fonte Blizzard italiana sufficiente per fissare:

- Brambleblade Ravine;
- Chief Hawkwind;
- Grull Hawkwind;
- Seer Graytongue;
- Meela Dawnstrider;
- Mountain Cougar Pelt;
- Bristleback Belt.

Questi termini restano in inglese nel prototipo.

## Nota su Wowhead italiano

Le pagine italiane Wowhead di Classic e Forever consultate per le quest 750, 755 e 757 mostrano intestazioni italiane dell'interfaccia ma mantengono il testo quest e molti nomi in inglese.

Uso corretto per ForeverITA:

- controllo Quest ID;
- confronto del testo sorgente;
- controllo che una quest/espressione esista;
- confronto Classic/Forever quando la pagina dedicata è disponibile.

Uso NON corretto:

- considerare automaticamente inglese = nome ufficiale italiano;
- considerare una pagina Wowhead italiana prova di localizzazione Blizzard.

## Provenienza delle quattro quest

Il testo sorgente delle quest 750, 755, 757 e 3093 è riscontrabile anche nelle pagine pubbliche Classic di Wowhead.

Questo è un controllo indipendente utile sulla provenienza del prototipo, ma gli `_sourceHashes` del runtime restano legati alla versione sorgente indicata nei record ForeverITA e non vengono rigenerati soltanto perché una pagina web mostra un testo simile.

## Modifiche applicate

Nel dataset Mulgore:

- `Camp Narache` → `Campo Narache`;
- riferimenti narrativi alla specie `Bristleback` → `Verrospino`;
- il nome oggetto `Bristleback Belt` resta inglese;
- i nomi NPC/località non verificati restano inglesi;
- gli hash sorgente non cambiano perché è cambiata soltanto la traduzione italiana.

## Stato

Le modifiche sono **DA TESTARE SU CLASSIC** solo per la resa testuale.

Non modificano API, collector o resolver.
