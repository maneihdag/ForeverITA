# Risultati test WoW Classic Era

Aggiornato: 2026-09-21.

Questi risultati dimostrano soltanto il funzionamento osservato su WoW Classic Era. Non provano compatibilità con WoW Forever.

## Ambiente

- WoW Classic Era 1.15.9
- Build 69722
- Interface 11509
- ForeverITA 0.0.2-alpha

## Sessione v0.1 engine freeze — 2026-09-21

**TESTATO SU CLASSIC**

Nel client WoW Classic Era reale è stato osservato quanto segue:

- l'addon corrente si è caricato correttamente;
- non sono comparsi errori Lua durante la sessione;
- `/fit selftest`: **28 PASS, 0 FAIL**;
- `/fit datatest`: **7 quest controllate, 0 errori, 0 warning, PASS**;
- la quest 757 è stata aperta realmente in gioco;
- il pannello ForeverITA è comparso correttamente accanto alla QuestFrame;
- titolo, descrizione e obiettivi italiani sono stati visualizzati correttamente;
- sono stati osservati correttamente i termini `Campo Narache`, `Verrospino`, `Madre Terra` e `Picco del Tuono`.

Questa sessione non prova la migrazione SavedVariables DB3 → DB4, tutti i bucket del collector, i casi `modified`/`incomplete`, il privacy fail-closed, tutte le fasi progress/completion o tutti i casi `_dynamicFields`. I relativi PASS offline restano separati dalle verifiche runtime.

## Decisione v0.1

**v0.1 ENGINE FREEZE CANDIDATE APPROVATO**

Non verranno introdotte nuove modifiche architetturali preventive. Il motore verrà modificato soltanto in presenza di bug reali o bloccanti; il lavoro passa ora alla crescita del database delle traduzioni.

## Test confermati

### Caricamento e SavedVariables

**TESTATO SU CLASSIC**

- ForeverITA carica correttamente.
- Le SavedVariables vengono scritte e lette correttamente.
- Nel test originale erano attivi collector DB schema 3 e record schema 2. Il branch corrente usa DB schema 4 / record schema 3 e questo aggiornamento è **DA TESTARE SU CLASSIC**.

### Collector locale

**TESTATO SU CLASSIC**

- Il collector registra Quest ID e testi disponibili.
- Il collector salva zona e map ID.
- Nessun record è stato scartato nel test.
- Nessun errore diagnostico è stato registrato.
- Una nuova quest viene salvata correttamente con titolo, descrizione e obiettivi.
- Una quest già raccolta può essere aggiornata in seguito senza creare un secondo record.

### Privacy

**TESTATO SU CLASSIC**

Il filtro privacy sostituisce correttamente il nome del personaggio presente nei testi dinamici con:

`<PLAYER>`

Il nome del personaggio non compare nei record analizzati dopo l'aggiornamento privacy.

### Merge tra eventi quest

**TESTATO SU CLASSIC**

La quest 755 è stata osservata in più momenti ed è arrivata a revisione 2 mantenendo nello stesso record:

- title;
- description;
- objectives;
- completion.

Questo conferma che il collector conserva i campi già raccolti e aggiunge quelli arrivati in eventi successivi senza cancellare i precedenti.

Il campo progress resta naturalmente assente quando la quest non fornisce o non espone un testo progress nel percorso osservato.

La quest 3093 conserva inoltre title, progress e completion nello stesso record, confermando il merge anche per quel percorso.

### Hash e versionamento

**TESTATO SU CLASSIC**

- nel test originale era attivo record schema 2; il branch corrente usa record schema 3, ancora **DA TESTARE SU CLASSIC**;
- hash q2 attivo;
- revision aumenta quando il contenuto raccolto della stessa quest si arricchisce/cambia;
- zona e map ID restano separati dal contenuto testuale.

## Stato della prima fase Classic

Il collector quest locale può ora essere considerato **TESTATO SU CLASSIC** per:

- raccolta silenziosa;
- Quest ID;
- titolo;
- descrizione;
- obiettivi;
- progress quando disponibile;
- completion;
- zona/map ID;
- SavedVariables;
- merge multi-evento;
- privacy del nome personaggio;
- hash/versionamento di base.

## Prossimo passo

Passare dalla sola raccolta alla prima prova reale del motore di traduzione con pochissime quest Classic, mantenendo i dati Classic separati dagli override Forever.

## Forever

Tutto quanto sopra resta **DA TESTARE SU FOREVER**.


### Prima UI di traduzione

**TESTATO SU CLASSIC**

Screenshot in-game della quest 757 conferma che:

- il pannello ForeverITA viene renderizzato correttamente accanto alla QuestFrame;
- titolo, descrizione e obiettivi italiani sono leggibili;
- la QuestFrame Blizzard resta separata e non viene modificata;
- lo scroll frame e il testo funzionano su Classic Era;
- il self-test riportava 13 pass e 0 fail durante la prova.

Dallo screenshot è emerso molto spazio vuoto nella parte inferiore del pannello. La UI è stata quindi resa più compatta e con altezza adattiva al contenuto.

L'apertura automatica del pannello senza `/fit show 757` e la chiusura automatica alla fine del dialogo sono state confermate in gioco. **TESTATO SU CLASSIC**.

### Apertura e chiusura automatica

**TESTATO SU CLASSIC**

Confermata in gioco:

- apertura automatica del pannello quando viene aperta una quest tradotta;
- chiusura automatica al termine/chiusura del dialogo;
- nessun comando manuale necessario.

### UI per fase della quest

**DA TESTARE SU CLASSIC**

Il pannello ora mostra solo i testi adatti alla fase corrente:

- QUEST_DETAIL → titolo, descrizione, obiettivi;
- QUEST_PROGRESS → titolo, progress;
- QUEST_COMPLETE → titolo, completion.

Questo evita di mostrare in anticipo testi di completamento già presenti nel database.
