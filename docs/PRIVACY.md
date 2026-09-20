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
