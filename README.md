# ForeverITA 🇮🇹

**ForeverITA** è un progetto open source nato con l'obiettivo di realizzare una traduzione italiana per **WoW Forever** attraverso un addon di World of Warcraft.

> ⚠️ **Progetto sperimentale in sviluppo. Compatibilità con WoW Forever in verifica.**

Il progetto è attualmente nelle sue prime fasi. Stiamo studiando il funzionamento del client, i limiti delle API degli addon e quali contenuti possano essere tradotti in maniera affidabile senza modificare direttamente i file originali del gioco.

ForeverITA non dispone ancora di una versione stabile destinata all'utilizzo quotidiano.

---

## 🎯 Obiettivo

L'obiettivo di ForeverITA è rendere il più possibile accessibile in italiano l'esperienza di gioco di WoW Forever.

L'idea non è creare una semplice raccolta di traduzioni, ma costruire un addon organizzato e aggiornabile capace di associare automaticamente i testi originali del gioco alle rispettive traduzioni italiane.

Tra i contenuti che intendiamo studiare e, dove tecnicamente possibile, tradurre:

* missioni;
* titoli e descrizioni delle missioni;
* obiettivi delle missioni;
* dialoghi degli NPC;
* testi narrativi;
* opzioni di dialogo;
* nomi e descrizioni visualizzati dall'interfaccia;
* tooltip;
* testi dell'interfaccia;
* altri contenuti testuali accessibili tramite le API degli addon.

La copertura effettiva dipenderà da ciò che il client di WoW Forever permette di intercettare e modificare tramite addon.

---

## 🚧 Stato del progetto

**Fase attuale: prototipo quest e preparazione della v0.1 Alpha.**

Prima di iniziare una traduzione su larga scala dobbiamo verificare:

* quale versione dell'API addon utilizza WoW Forever;
* quali eventi e funzioni Lua sono disponibili;
* quali testi possono essere intercettati;
* quali elementi dell'interfaccia possono essere modificati;
* come identificare in maniera affidabile missioni, NPC e altri contenuti;
* come gestire aggiornamenti del gioco senza rompere le traduzioni;
* quanto sia possibile tradurre senza modificare direttamente il client.

Le prime versioni di ForeverITA saranno quindi considerate **Alpha sperimentali**.

Potrebbero esserci:

* testi mancanti;
* traduzioni incomplete;
* testi che rimangono in inglese;
* problemi di compatibilità;
* cambiamenti frequenti nella struttura dell'addon.

### Stato tecnico attuale

Dati pubblici verificati online al 20 settembre 2026:

* WoW Forever Beta: 1.60.1
* build iniziale documentata: 69893
* build segnalata nei test pubblici più recenti: 69913
* Interface: 16001
* ForeverITA: prototipo diagnostico non ancora validato direttamente sul client Forever

La disponibilità delle singole API e il comportamento dell’interfaccia devono ancora essere verificati direttamente in gioco. I report pubblici sul build 69913 indicano inoltre un problema di ripristino delle SavedVariables tra sessioni; per ForeverITA resta **DA TESTARE SU FOREVER**.


### Modalità di sviluppo attuale

Per non interrompere continuamente lo sviluppo, i test manuali vengono ora accumulati e svolti in una sessione dedicata.

Le funzioni non ancora provate restano marcate **DA TESTARE SU CLASSIC** o **DA TESTARE SU FOREVER** e non vengono considerate verificate solo perché il codice è stato scritto.

Il backlog dei controlli è in `docs/DEFERRED_TESTS.md`.

### Ambiente di sviluppo temporaneo: WoW Classic Era

Finché non avremo accesso diretto a WoW Forever, useremo **WoW Classic Era** come banco di prova reale.

Su Classic possiamo verificare:

* caricamento dell'addon e del file `.toc`;
* errori Lua;
* SavedVariables;
* UI di base;
* eventi e lettura delle quest Vanilla;
* collector delle quest mancanti;
* funzionamento del motore dati.

Questo **non significa** che Classic e Forever siano equivalenti.

Ogni risultato sarà distinto in:

* **TESTATO SU CLASSIC**;
* **DA TESTARE SU FOREVER**;
* **VERIFICATO SU FOREVER**, solo dopo un test reale sul client Forever.

Tutto ciò che può cambiare tra Classic e Forever viene isolato nella cartella `Compat/`.


---

## 🧩 Come dovrebbe funzionare

L'idea iniziale è mantenere separati:

1. il codice dell'addon;
2. il sistema che identifica i testi del gioco;
3. il database delle traduzioni italiane.

In questo modo sarà possibile aggiornare le traduzioni senza dover riscrivere continuamente il funzionamento principale dell'addon.

Un possibile esempio:

```text
ForeverITA/
├── ForeverITA.toc
├── Core.lua
├── Compat/
│   ├── API.lua
│   ├── Client.lua
│   ├── Privacy.lua
│   ├── Storage.lua
│   ├── Quest.lua
│   ├── UI.lua
│   └── TranslationUI.lua
├── Core/
│   ├── DataRegistry.lua
│   └── RecordFormat.lua
├── Modules/
│   ├── MissingQuestCollector.lua
│   ├── QuestTranslation.lua
│   └── QuestDebug.lua
├── Data/
│   ├── Classic_it/
│   │   ├── Quests.lua
│   │   └── Mulgore.lua
│   └── Forever_it/
├── Dev/
│   ├── SelfTest.lua
│   ├── ClassicSmokeTest.lua
│   └── TranslationDataValidator.lua
└── tools/
    ├── import_quests.py
    └── test_import_quests.py
```

La struttura definitiva verrà decisa durante lo sviluppo e potrà cambiare man mano che comprenderemo meglio il funzionamento di WoW Forever.

---

## 🇮🇹 Traduzioni

Uno degli obiettivi principali è mantenere uno stile coerente con la terminologia italiana di World of Warcraft quando esiste già una traduzione ufficiale equivalente.

Quando non esiste un riferimento italiano ufficiale, verrà scelta una traduzione cercando di rispettare:

* significato originale;
* tono del personaggio;
* contesto narrativo;
* terminologia dell'universo di Warcraft;
* coerenza tra missioni, luoghi, oggetti e personaggi.

Le traduzioni non verranno quindi effettuate come semplice sostituzione parola per parola.

---

## 🔍 Identificazione dei contenuti

Quando possibile, ForeverITA cercherà di associare le traduzioni a identificatori stabili come:

```text
QuestID
NPC ID
Item ID
Spell ID
```

Questo dovrebbe permettere di evitare sistemi troppo fragili basati esclusivamente sul confronto diretto delle stringhe inglesi.

Per i contenuti che non dispongono di identificatori utilizzabili sarà necessario studiare sistemi alternativi.

---

## ⚙️ Compatibilità

La compatibilità con **WoW Forever è attualmente in fase di verifica**.

Al momento non possiamo garantire:

* la traduzione completa del gioco;
* la compatibilità con ogni versione del client;
* la traduzione di elementi protetti dall'interfaccia;
* la possibilità di modificare ogni testo visualizzato;
* la compatibilità con altri addon.

Questi aspetti verranno verificati progressivamente attraverso test direttamente in gioco.

---

## 🗺️ Roadmap

### Fase 0 — Ricerca

* [ ] Identificare versione e API disponibili
* [ ] Verificare il caricamento degli addon
* [ ] Studiare struttura delle missioni
* [ ] Studiare dialoghi NPC
* [ ] Individuare i limiti tecnici del client

### Fase 1 — Prototipo

* [x] Creare struttura base di ForeverITA
* [x] Creare `ForeverITA.toc`
* [x] Creare il core Lua
* [x] Separare il livello `Compat`
* [x] Preparare collector e SavedVariables
* [x] Rendere il collector silenzioso e versionare i record
* [x] Preparare hash/deduplicazione per un futuro Companion
* [x] Verificare il caricamento reale su Classic Era
* [x] Verificare una piccola UI su Classic Era
* [x] Verificare SavedVariables su Classic Era
* [x] Leggere 2-3 quest Vanilla reali su Classic Era
* [ ] Ripetere i test principali su WoW Forever

### Fase 2 — Prima traduzione

* [x] Intercettare una missione su Classic Era
* [x] Identificare la missione tramite ID
* [x] Preparare la prima traduzione reale di prova (Quest 757)
* [x] Creare un primo piccolo gruppo di 4 quest reali di Mulgore
* [x] Separare i dati reali per zona (`Data/Classic_it/Mulgore.lua`)
* [x] Verificare in gioco il pannello italiano della Quest 757
* [x] Mostrare titolo, descrizione e obiettivi italiani nel pannello di prova
* [x] Tradurre un primo piccolo campione reale di testo narrativo
* [x] Testare apertura/chiusura automatica dell'interfaccia
* [ ] Testare in batch dettaglio/progresso/completamento e le nuove quest

### Fase 3 — Sistema di localizzazione

* [x] Separare codice e database
* [x] Creare il primo database delle missioni
* [ ] Creare database dei dialoghi
* [x] Creare sistema di fallback Classic → Forever override
* [x] Gestire le quest non ancora tradotte tramite collector
* [x] Gestire traduzioni parziali tramite bucket `incomplete` (DA TESTARE SU CLASSIC)
* [x] Aggiungere validator del database traduzioni (`/fit datatest`, DA TESTARE SU CLASSIC)
* [x] Aggiungere importer di sviluppo JSON → Lua (DA REVISIONARE/TESTARE)

### Fase 4 — Espansione

* [ ] Aumentare progressivamente il numero di missioni
* [ ] Tradurre dialoghi NPC
* [ ] Tradurre altri elementi supportati
* [ ] Migliorare prestazioni e stabilità

### Fase 5 — Community

* [ ] Definire linee guida per le traduzioni
* [ ] Accettare segnalazioni
* [ ] Accettare correzioni
* [ ] Valutare contributi esterni
* [ ] Preparare versioni pubbliche dell'addon

---

## 📦 Installazione

ForeverITA non dispone ancora di una release pubblica stabile.

Quando sarà disponibile una prima versione utilizzabile, l'installazione dovrebbe seguire il normale sistema degli addon di World of Warcraft:

```text
World of Warcraft/
└── Interface/
    └── AddOns/
        └── ForeverITA/
```

Le istruzioni definitive verranno pubblicate insieme alla prima release.

---

## 🧪 Versioni

Durante lo sviluppo utilizzeremo indicativamente queste fasi:

**Prototype**
Test tecnici e studio del funzionamento del client.

**Alpha**
Addon funzionante ma con pochissimi contenuti tradotti e possibili problemi.

**Beta**
Sistema stabile con una quantità significativa di contenuti tradotti.

**Stable**
Versione considerata sufficientemente affidabile per un utilizzo normale.

---

## 🤝 Contribuire

ForeverITA viene sviluppato pubblicamente fin dalle prime fasi.

In futuro sarà possibile contribuire attraverso:

* segnalazione di testi non tradotti;
* correzione di errori;
* miglioramento delle traduzioni;
* test di compatibilità;
* sviluppo Lua;
* documentazione;
* segnalazione di bug.

Le modalità di contribuzione verranno definite quando la struttura tecnica del progetto sarà sufficientemente stabile.

---

## 🐛 Segnalazione problemi

Quando inizieranno i test pubblici, i problemi potranno essere segnalati tramite la sezione **Issues** di GitHub.

Una buona segnalazione dovrebbe includere, quando possibile:

* versione di ForeverITA;
* punto del gioco in cui compare il problema;
* testo originale;
* testo tradotto;
* eventuale QuestID/NPC ID;
* screenshot;
* altri addon attivi.

---

## 🔐 Perimetro tecnico

ForeverITA deve restare **sempre un normale addon World of Warcraft**.

Il progetto usa soltanto:

* file `.lua`, `.toc` e, quando necessario, `.xml`;
* API esposte dal client agli addon;
* eventi dell'interfaccia;
* SavedVariables;
* UI addon;
* database locali.

ForeverITA non usa e non deve dipendere da:

* DLL esterne;
* injection nel processo di WoW;
* lettura diretta della memoria;
* modifica dell'eseguibile o di file protetti;
* bot o automazione del gameplay;
* strumenti esterni che estraggono dati aggirando le API addon;
* tecniche per aggirare protezioni o limitazioni imposte dal client.

Se una soluzione esterna usa metodi poco chiari o invasivi, non viene integrata automaticamente: viene prima analizzata e confrontata con le regole Blizzard aggiornate.

Il progetto riguarda esclusivamente la **localizzazione e visualizzazione dei contenuti testuali** accessibili attraverso il normale sistema addon.

---

## 🗃️ Raccolta dati e privacy

ForeverITA può raccogliere **in locale e in silenzio** i testi di quest mancanti o modificati incontrati durante il gioco.

Il collector usa soltanto API/eventi dell'addon e SavedVariables.

Può salvare, quando disponibili:

* Quest ID;
* titolo, descrizione, obiettivi, progress e completion/reward text;
* zona/map ID come contesto;
* versione client e addon;
* hash/versione del record per evitare duplicati.

Se il gioco inserisce il nome del personaggio dentro il testo di una quest, ForeverITA lo sostituisce con `<PLAYER>` prima di salvarlo. Non raccoglie intenzionalmente nome del personaggio, account/BattleTag, chat, inventario, lista amici o altri dati personali non necessari.

Durante il normale gioco il collector **non mostra messaggi in chat**.

### Companion futuro

In futuro potrà esistere un Companion esterno **opzionale** per condividere automaticamente i record utili con il database ForeverITA.

L'addon WoW non comunica direttamente con Internet.

Il Companion:

* non sarà necessario per usare le traduzioni;
* richiederà consenso esplicito alla prima configurazione;
* potrà essere disattivato in seguito;
* invierà soltanto record nuovi o modificati;
* leggerà esclusivamente i file ForeverITA necessari;
* non dovrà leggere memoria di WoW, traffico di rete del gioco o altri dati non necessari.

Il Companion **non è implementato nella prima fase**. Prima viene completato e testato il collector locale.

Vedi `docs/COLLECTOR_FORMAT.md`, `docs/COMPANION_DESIGN.md` e `docs/PRIVACY.md`.

Per il perimetro della prima Alpha e la strategia dei dati: `docs/V0_1_SCOPE.md` e `docs/DATA_SOURCE_STRATEGY.md`.

Indice completo della documentazione: `docs/README.md`.

---

## 📖 Open source

Il codice sorgente di ForeverITA è disponibile pubblicamente per permettere trasparenza, studio e collaborazione.

Il codice originale di ForeverITA è distribuito con licenza **MIT**.

La licenza del codice non concede diritti sui marchi o sui contenuti di World of Warcraft appartenenti a Blizzard Entertainment o ad altri titolari. Dettagli: `LICENSE` e `docs/LICENSING.md`.

---

## ❤️ Supporta ForeverITA

ForeverITA è e resterà un progetto gratuito e open source.

Se vuoi sostenere volontariamente lo sviluppo del progetto, i test, la manutenzione e il lavoro necessario per ampliare progressivamente la traduzione italiana, puoi farlo tramite:

**☕ PayPal:** maneihdag@gmail.com

Le donazioni sono completamente facoltative.

Donare non permette di ottenere versioni premium, funzionalità aggiuntive, traduzioni esclusive, accesso anticipato o altri vantaggi rispetto agli altri utenti.

Tutte le versioni pubbliche di ForeverITA saranno disponibili gratuitamente.

Il supporto economico serve esclusivamente a sostenere lo sviluppo e la manutenzione del progetto.

---

## ⚠️ Disclaimer

**ForeverITA è un progetto amatoriale, indipendente e non ufficiale.**

Non è affiliato, sponsorizzato, approvato o supportato da Blizzard Entertainment né dagli sviluppatori o gestori di WoW Forever.

World of Warcraft, Warcraft, Blizzard Entertainment e tutti i relativi nomi, marchi, immagini, personaggi e contenuti appartengono ai rispettivi proprietari.

ForeverITA non distribuisce il client di gioco né file originali del client Blizzard. Il repository può contenere traduzioni originali, identificatori tecnici e riferimenti necessari alla localizzazione; i diritti sui contenuti e sui marchi di World of Warcraft restano dei rispettivi titolari.

---

## 📌 Nota sullo sviluppo

Il repository viene reso pubblico già durante la fase di costruzione.

Questo significa che parte del codice presente potrebbe essere:

* incompleto;
* sperimentale;
* temporaneo;
* destinato a essere riscritto.

La presenza di una funzionalità nel repository non significa necessariamente che sia già pronta per l'utilizzo.

---

**ForeverITA**

*Traduzione italiana sperimentale per WoW Forever.*
