# AGENTS.md — ForeverITA

Questo file definisce le regole operative per Codex e per qualunque contributore automatico o umano.

## Obiettivo

ForeverITA è un addon sperimentale per la localizzazione italiana di World of Warcraft: Forever.

Il progetto deve separare sempre:

- motore addon;
- compatibilità/API del client;
- moduli funzionali;
- dati di traduzione Classic;
- override specifici Forever;
- dati diagnostici raccolti in gioco.

## Regole tecniche

1. Non assumere mai che WoW Forever usi le stesse API di Classic.
2. Non assumere mai che una API presente abbia lo stesso comportamento di Retail/Mainline.
3. Tutte le dipendenze da build, interface o flavor devono stare in `Compat/Client.lua`.
4. Le letture quest devono passare da `Compat/Quest.lua`, non essere sparse nei moduli.
5. I moduli non devono contenere database di traduzione hard-coded.
6. `Data/Forever_it` ha precedenza su `Data/Classic_it` soltanto quando il flavor dati è Forever.
7. Un override Forever può modificare solo alcuni campi; i campi non modificati possono fare fallback al livello Classic.
8. Una traduzione Classic usata su Forever non è considerata automaticamente verificata.
9. Le nuove funzionalità devono degradare in modo sicuro quando una API manca.
10. ForeverITA deve restare un normale addon WoW: niente DLL, injection, lettura memoria, modifica del client, bot, automazione gameplay o aggiramento delle protezioni Blizzard.

## Ricerca e verifica

Prima di introdurre o cambiare una API WoW:

- verificare online documentazione aggiornata;
- cercare evidenza recente specifica di Forever quando disponibile;
- documentare ciò che è verificato e ciò che è ancora "da testare su Forever";
- non inventare firme, eventi o comportamenti.

## Codice e licenze esterne

Repository di riferimento principali:

- Daribon/QuestTranslator
- leoaviana/QuestTradutor
- Questie/Questie
- CMaNGOS Vanilla/localized DB
- repository Forever recenti elencati in `THIRD_PARTY.md`

Prima di copiare codice o dati:

- verificare licenza;
- verificare provenienza;
- verificare compatibilità;
- mantenere attribuzione richiesta;
- non importare codice privo di licenza esplicita;
- non importare codice GPL nel core senza una decisione esplicita sulla licenza di ForeverITA.

Studiare una soluzione esterna come riferimento è consentito; copiarla non lo è automaticamente.

## Dati di traduzione

Ogni futuro record reale dovrebbe avere provenienza documentata quando possibile.

Non importare migliaia di quest in blocco senza:

- fonte chiara;
- licenza/diritti valutati;
- normalizzazione dello schema;
- validazione ID;
- controllo terminologico;
- strategia di aggiornamento.

Le fixture sintetiche con ID 990000001+ sono solo test interni e non rappresentano contenuti Blizzard.

## Collector

Il collector deve:

- essere event-driven;
- non scansionare continuamente il gioco;
- salvare solo dati utili alla localizzazione;
- usare limiti di crescita;
- evitare dati personali non necessari;
- distinguere quest senza traduzione da quest Classic da verificare su Forever;
- non dare per scontata la persistenza SavedVariables finché il bug della beta non è verificato come risolto.

## Test

Prima di dichiarare una funzione compatibile:

- test offline/logico dove possibile;
- test su Classic solo per motore/dati quando appropriato;
- test reale su Forever per API, eventi e UI;
- riportare build e interface usate nel test.

Nessun test su Classic o Retail prova da solo la compatibilità con Forever.

## Classic Era come banco di prova

Il progetto può essere sviluppato e testato su WoW Classic Era quando Forever non è disponibile.

Regole:

- Classic Era è un laboratorio, non il target finale;
- un comportamento verificato su Classic va marcato **TESTATO SU CLASSIC**;
- non dichiararlo compatibile Forever senza un test reale su Forever;
- tutto ciò che può cambiare tra client deve stare in `Compat/`;
- non introdurre dipendenze da frame o API Classic direttamente in Core, Modules o Data;
- usare 2-3 quest reali alla volta per i test, non importare database enormi alla cieca.


## Perimetro tecnico obbligatorio

Sono ammessi soltanto:

- `.lua`, `.toc`, `.xml`;
- API WoW esposte agli addon;
- eventi UI;
- SavedVariables;
- UI addon;
- database locali dell'addon.

Sono esclusi:

- DLL esterne;
- process injection;
- lettura diretta della memoria;
- modifica dell'eseguibile o di file protetti;
- bot e automazione del gameplay;
- strumenti esterni che estraggono dati aggirando le API addon;
- qualsiasi tentativo di bypassare protected functions, Secret Values o altre restrizioni del client.

Se un repository o uno strumento usa uno di questi metodi, non integrarlo. Segnalarlo prima.

Se una tecnica è poco chiara o non documentata:

1. fermarsi;
2. verificare online le regole Blizzard aggiornate;
3. classificare la tecnica come addon/API ufficiale, dubbia oppure esterna/invasiva;
4. non procedere finché il dubbio non è risolto.

Vedere anche `docs/BLIZZARD_COMPLIANCE.md`.
