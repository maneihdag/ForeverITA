# Privacy e raccolta dati

## Addon WoW

Il collector locale usa le API dell'addon e SavedVariables.

Durante il normale gioco lavora in silenzio.

Può salvare:

- Quest ID;
- testi della quest;
- zona/map ID;
- versione client;
- versione addon;
- hash e revisione del record.

Prima del salvataggio, ForeverITA rimuove dal testo eventuali riferimenti al nome del personaggio e li sostituisce con `<PLAYER>`.

Non salva:

- nome personaggio;
- account/BattleTag;
- chat;
- inventario;
- amici;
- gilda;
- posta;
- dati personali non necessari.

## Condivisione

La raccolta locale e la condivisione sono due cose diverse.

L'addon può raccogliere localmente i record utili senza inviarli da nessuna parte.

La futura condivisione automatica richiederà un Companion opzionale e consenso esplicito.

## Companion

Il Companion non è necessario per usare ForeverITA.

Senza consenso:

- nessun upload.

Con consenso:

- invia solo record nuovi o modificati;
- usa ID/hash per evitare duplicati;
- può essere disattivato in qualsiasi momento.

Il README e la futura pagina download devono indicare chiaramente queste condizioni.

## Confini della sostituzione del nome

Il privacy scrubber sostituisce il nome del personaggio solo quando compare come token separato.

Non deve sostituire una sequenza uguale al nome quando quella sequenza è parte di una parola più lunga.

Esempio sintetico:

- personaggio `Ash`;
- `Ash, torna qui.` → `<PLAYER>, torna qui.`;
- `Ashenvale` → resta `Ashenvale`.

La sostituzione continua a funzionare accanto a punteggiatura e forme possessive, inclusa punteggiatura UTF-8 comune come il trattino lungo. Gli alias vengono provati dal più lungo al più corto per evitare sostituzioni parziali quando è disponibile anche la forma `Nome-Reame`.

Stato: **DA TESTARE SU CLASSIC**.

## Fail-closed del collector

La lettura del nome del giocatore può essere limitata da API/Secret Values su alcuni client.

Per evitare che un testo personalizzato venga salvato senza poter rimuovere il nome:

- ogni snapshot quest parte come `privacySafe = false`;
- il privacy layer lo marca sicuro soltanto dopo aver ottenuto almeno un alias del giocatore tramite le normali API addon;
- se l'alias non è disponibile, il collector NON salva il testo e registra soltanto il contatore diagnostico `collector_privacy_alias_unavailable`;
- nessun tentativo di bypassare Secret Values viene effettuato.

Questo comportamento privilegia la privacy rispetto alla completezza del collector.

Anche `/fit quest` evita di stampare i testi della quest se lo snapshot è marcato `privacySafe = false`; mostra soltanto le informazioni diagnostiche non testuali necessarie.

Stato: **DA TESTARE SU CLASSIC** e **DA TESTARE SU FOREVER**.
