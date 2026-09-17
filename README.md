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

**Fase attuale: ricerca e prototipo iniziale.**

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

Dati rilevati sul client beta al 17 settembre 2026:

* WoW Forever Beta: 1.60.1
* Build: 69893
* Interface: 16001
* ForeverITA: prototipo diagnostico non ancora validato direttamente sul client Forever

La disponibilità delle singole API e il comportamento dell’interfaccia devono ancora essere verificati direttamente in gioco.


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
│
├── ForeverITA.toc
├── Core.lua
│
├── Data/
│   ├── Quests.lua
│   ├── NPC.lua
│   ├── Dialogues.lua
│   └── UI.lua
│
├── Localization/
│   └── itIT.lua
│
└── README.md
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

* [ ] Creare struttura base di ForeverITA
* [ ] Creare `ForeverITA.toc`
* [ ] Creare il core Lua
* [ ] Verificare il caricamento dell'addon
* [ ] Visualizzare un messaggio di conferma in gioco

### Fase 2 — Prima traduzione

* [ ] Intercettare una missione
* [ ] Identificare la missione tramite ID
* [ ] Sostituire titolo e descrizione
* [ ] Tradurre obiettivi e testo narrativo
* [ ] Testare il comportamento dell'interfaccia

### Fase 3 — Sistema di localizzazione

* [ ] Separare codice e database
* [ ] Creare database delle missioni
* [ ] Creare database dei dialoghi
* [ ] Creare sistema di fallback
* [ ] Gestire testi non ancora tradotti

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

## 🔐 Modifiche al client

Uno degli obiettivi del progetto è lavorare, quando possibile, esclusivamente attraverso il normale sistema addon di World of Warcraft.

ForeverITA non nasce con l'obiettivo di:

* modificare gli eseguibili del gioco;
* alterare direttamente il client;
* aggirare sistemi di protezione;
* automatizzare il gameplay;
* fornire vantaggi di gioco.

Il progetto riguarda esclusivamente la **localizzazione e visualizzazione dei contenuti testuali** accessibili attraverso le funzionalità consentite agli addon.

---

## 📖 Open source

Il codice sorgente di ForeverITA è disponibile pubblicamente per permettere trasparenza, studio e collaborazione.

Una licenza open source definitiva verrà scelta prima della distribuzione delle prime versioni utilizzabili.

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

ForeverITA non distribuisce il client di gioco né contenuti proprietari del gioco.

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
