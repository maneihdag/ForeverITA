# Regole tecniche e conformità Blizzard

Aggiornato: 2026-09-20.

ForeverITA deve restare un normale addon World of Warcraft sviluppato nel perimetro previsto dagli addon Blizzard.

## Tecniche consentite nel progetto

ForeverITA può usare soltanto:

- file `.lua`, `.toc` e, quando serve, `.xml`;
- API esposte dal client WoW agli addon;
- eventi dell'interfaccia;
- SavedVariables;
- frame e UI create tramite il sistema addon;
- database locali caricati dall'addon.

## Tecniche escluse

ForeverITA non deve usare, proporre o integrare automaticamente:

- DLL esterne;
- injection nel processo di World of Warcraft;
- lettura o scansione diretta della memoria del processo;
- modifica dell'eseguibile;
- modifica di file protetti del client;
- hook nativi esterni al sistema addon;
- bot;
- automazione del gameplay;
- input broadcasting;
- strumenti esterni che leggono dati dal client aggirando le API disponibili agli addon;
- tecniche pensate per aggirare restrizioni, protected functions, Secret Values o altre protezioni Blizzard.

## Regola per strumenti e repository esterni

Prima di adottare una soluzione esterna bisogna controllare:

1. come funziona tecnicamente;
2. quali API o meccanismi usa;
3. licenza e provenienza;
4. compatibilità con le regole Blizzard aggiornate.

Classificazione:

- **ADDON/API UFFICIALI** → utilizzabili, dopo verifica tecnica e licenza;
- **TECNICA NON CHIARA / NON DOCUMENTATA** → fermarsi, fare ricerca e segnalarla prima di integrarla;
- **METODO ESTERNO O INVASIVO** → non integrare in ForeverITA.

Se un repository mescola codice addon normale con componenti esterni, ForeverITA può eventualmente studiare soltanto la parte addon lecita e separabile. Il componente esterno non deve diventare una dipendenza del progetto.

## Collector

Il collector di ForeverITA deve leggere solo ciò che il client espone normalmente all'addon durante il gioco.

È consentito salvare queste osservazioni in SavedVariables.

Non deve:

- leggere memoria del processo;
- interrogare file interni protetti del client;
- usare packet sniffing;
- usare process injection;
- invocare strumenti esterni per ottenere dati non esposti alle API addon.

## Regola di prudenza

Quando non è chiaro se una tecnica rientri nel normale sistema addon:

**NON IMPLEMENTARE.**

Prima:

- verificare le regole Blizzard aggiornate;
- cercare documentazione API;
- spiegare il dubbio;
- aspettare una decisione esplicita prima di procedere.

## Fonti Blizzard di riferimento

La UI Add-On Development Policy richiede che gli addon rispettino ToU/EULA, che il codice sia visibile e che Blizzard possa limitare funzionalità addon.

Blizzard vieta inoltre hack, bot e software di terze parti non autorizzato usato per modificare o automatizzare l'esperienza di gioco.

ForeverITA deve restare interamente dentro il normale sistema addon.
