# Test rimandati — batch di verifica

Decisione: 2026-09-20.

Per velocizzare lo sviluppo, i nuovi cambiamenti non vengono testati uno per uno dal giocatore.

Continuiamo a sviluppare e accumuliamo qui i controlli da eseguire insieme in una sessione dedicata.

Questo non trasforma le funzioni non provate in funzioni verificate.

## Già testato su Classic

- caricamento addon;
- SavedVariables: verificare sia `/reload` sia chiusura completa + riavvio del client, perché sul build 69913 esistono report di file scritti ma non riletti;
- collector silenzioso;
- raccolta quest;
- merge multi-evento del collector;
- privacy nome personaggio;
- prima UI traduzione;
- apertura automatica pannello;
- chiusura automatica pannello;
- Quest 757 nel pannello italiano.

## Da testare nel prossimo batch Classic

- UI compatta/adattiva dopo il restyling;
- visualizzazione diversa per QUEST_DETAIL;
- visualizzazione diversa per QUEST_PROGRESS;
- visualizzazione diversa per QUEST_COMPLETE;
- Quest 755 con completion;
- Quest 750;
- Quest 3093 con detail + progress + completion;
- sostituzione `<PLAYER>` con il nome solo a schermo, senza salvarlo;
- pannello nascosto quando manca la traduzione della fase corrente;
- verificare che campi vuoti non vengano trattati come tradotti;
- verificare che la label Forever rispetti `_meta.status` e non dichiari verificati record draft;
- caricamento dati da `Data/Classic_it/Mulgore.lua`;
- rimozione dal bucket missing quando una traduzione entra nel database;
- rilevamento modified tramite hash per campo;
- nessun messaggio automatico indesiderato in chat;
- self-test dopo tutte le modifiche;
- verificare che un flavor sconosciuto non faccia fallback silenzioso a Classic;
- verificare che il collector non raccolga dati quando il flavor client non è riconosciuto;
- verificare il rifiuto di QuestID duplicati nello stesso layer;
- assenza di errori Lua;
- lettura mapID tramite il controllo Compat senza errori o valori non accessibili.

## Da testare su Forever

Tutto ciò che dipende dal client reale Forever resta **DA TESTARE SU FOREVER**, compresi:

- caricamento TOC;
- API/eventi;
- Secret Values;
- SavedVariables;
- QuestFrame e pannello ForeverITA;
- fallback Classic;
- override Forever;
- collector;
- confronto hash;
- usare Quest 755 per verificare la gestione dei campi dinamici: il template Classic/Forever usa `<class>`, mentre il collector riceve la classe già renderizzata;
- confrontare 750, 755, 757 e 3093 sul client reale; le fonti pubbliche non dimostrano al momento un override Forever tra queste quattro.
