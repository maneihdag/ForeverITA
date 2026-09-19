# Risultati test WoW Classic Era

Aggiornato: 2026-09-20.

Questi risultati dimostrano soltanto il funzionamento osservato su WoW Classic Era. Non provano compatibilità con WoW Forever.

## Ambiente

- WoW Classic Era 1.15.9
- Build 69722
- Interface 11509
- ForeverITA 0.0.2-alpha

## Test confermati

### Caricamento e SavedVariables

**TESTATO SU CLASSIC**

- ForeverITA carica correttamente.
- Le SavedVariables vengono scritte e lette correttamente.
- Schema collector 3 e record schema 2 sono attivi.

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

- record schema 2 attivo;
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
