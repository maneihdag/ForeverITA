# ForeverITA v0.1 — piano test batch

Aggiornato: 2026-09-20.

## Principio

I test manuali vengono accumulati e svolti in sessioni dedicate. Non serve reinstallare e provare ForeverITA dopo ogni singolo commit.

Questo piano serve per la prima Alpha quest.

## Batch Classic Era

Preparazione:

- usare l'ultima build del branch di sviluppo;
- mantenere una copia del SavedVariables collector prima del test se contiene dati utili;
- evitare altri addon che modificano pesantemente la QuestFrame quando si verifica la UI.

Sequenza:

1. entrare nel gioco e controllare che ForeverITA venga caricato senza errori Lua;
2. `/fit status` — verificare Classic Era e interface attesa;
3. `/fit selftest` — tutti i test devono passare, inclusi normalizzazione hash, `fieldHashes`, fallback metadata e privacy boundary;
4. `/fit datatest` — dopo l'implementazione del validator, nessun errore dati;
5. `/fit classictest` — nessun FAIL inatteso;
6. `/fit data 990000001` — verificare la fixture Classic;
7. aprire almeno una quest con traduzione disponibile e verificare apertura automatica del pannello;
8. verificare almeno una fase DETAIL;
9. quando possibile verificare PROGRESS;
10. quando possibile verificare COMPLETE;
11. verificare che `<PLAYER>` venga mostrato come nome soltanto nella UI e non venga salvato nel collector;
12. incontrare almeno una quest non tradotta e verificare che il collector la registri senza messaggi automatici e con `fieldHashes` per i campi osservati;
13. verificare almeno un caso di traduzione parziale dopo l'implementazione del bucket `incomplete`;
14. `/fit svtest start` → `/reload` → `/fit svtest check`;
15. uscire dal gioco e controllare il file SavedVariables generato;
16. verificare che durante il normale gameplay non compaiano messaggi collector automatici.

## Batch Forever

Da eseguire solo quando avremo accesso al client reale.

Ordine iniziale:

1. verificare che il TOC venga accettato e che l'addon venga caricato;
2. `/fit status` — registrare version, build, interface e flavor;
3. controllare eventuali errori Secret Values/API;
4. `/fit selftest` e `/fit datatest`;
5. aprire una quest e verificare QUEST_DETAIL/ID/testi;
6. verificare PROGRESS e COMPLETE;
7. verificare pannello ForeverITA;
8. verificare fallback Classic con etichetta `DA VERIFICARE SU FOREVER`;
9. verificare un override Forever quando ne avremo uno reale;
10. verificare collector `missing`, `incomplete`, `verifyClassic` e `modified` con casi disponibili;
11. SavedVariables: testare `/reload`;
12. SavedVariables: chiudere completamente il client, riaprirlo e verificare il ripristino;
13. controllare il file SavedVariables su disco senza usare memoria, injection o strumenti invasivi.

## Criterio di stop

Se un test Forever mostra:

- API mancante;
- Secret Value non accessibile;
- evento con comportamento diverso;
- SavedVariables non ripristinate;
- errore Lua legato al client;

non aggiungere workaround esterni. Annotare il risultato e correggere soltanto attraverso le normali API addon disponibili.

## Risultati

I risultati confermati vanno riportati in:

`docs/CLASSIC_TEST_RESULTS.md`

oppure nella futura sezione risultati Forever.
