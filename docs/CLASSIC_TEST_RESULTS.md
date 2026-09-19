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

### Privacy

**TESTATO SU CLASSIC**

Il filtro privacy sostituisce correttamente il nome del personaggio presente nei testi dinamici con:

`<PLAYER>`

Il nome del personaggio non compare nel record raccolto analizzato dopo l'aggiornamento privacy.

### Merge tra eventi quest

**PARZIALMENTE TESTATO SU CLASSIC**

Nel test della quest 3093 lo stesso record ha conservato insieme:

- titolo;
- progress;
- completion.

Questo conferma che eventi diversi possono arricchire lo stesso record senza creare record separati.

Descrizione e obiettivi non erano presenti nel secondo file di test. Non è ancora dimostrato se questo dipenda dal fatto che la quest fosse già stata accettata prima dell'aggiornamento oppure da un problema di cattura.

Per verificare completamente il merge bisogna accettare una nuova quest con la versione aggiornata già caricata e poi completarla.

## Prossimo test

1. Avviare WoW con l'ultima versione di ForeverITA già caricata.
2. Accettare una quest nuova.
3. Progredire nella quest.
4. Consegnarla.
5. Eseguire `/reload`.
6. Controllare che lo stesso record contenga:
   - title
   - description
   - objectives
   - progress, se disponibile
   - completion
7. Verificare che eventuali riferimenti al nome del personaggio siano sostituiti da `<PLAYER>`.

## Forever

Tutto quanto sopra resta **DA TESTARE SU FOREVER**.
