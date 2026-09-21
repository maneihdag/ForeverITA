# Companion ForeverITA — progetto futuro

Stato: **NON IMPLEMENTATO**.

Il Companion sarà opzionale e separato dall'addon WoW.

ForeverITA deve funzionare normalmente anche senza Companion.

## Flusso previsto

```text
WoW
  ↓
ForeverITA raccoglie testi mancanti/modificati
  ↓
SavedVariables
  ↓
Companion opzionale
  ↓
controllo ID + hash
  ↓
backend ForeverITA
```

L'addon WoW non comunica direttamente con Internet.

## Cosa può leggere il Companion

Solo:

- il file SavedVariables di ForeverITA necessario alla raccolta;
- il proprio file di configurazione locale.

Non deve leggere:

- memoria del processo WoW;
- traffico di rete del gioco;
- altri file WTF non necessari;
- chat;
- inventario;
- lista amici;
- BattleTag/account;
- dati personali non indispensabili.

Il percorso locale del file può servire per trovarlo, ma non deve essere inviato al backend.

## Consenso

Al primo avvio il Companion non deve inviare nulla finché l'utente non sceglie.

Testo proposto:

> Contribuisci automaticamente a ForeverITA. Il Companion può inviare i testi di gioco mancanti incontrati durante il gioco per migliorare il database italiano. Non vengono inviati nome del personaggio, account, chat o altri dati personali non necessari.

Scelte:

- Accetta;
- Rifiuta.

La scelta deve poter essere modificata in seguito.

Rifiutare non deve limitare le traduzioni o l'uso di ForeverITA.

## Sincronizzazione futura

Dopo il consenso:

1. il Companion osserva il file ForeverITA;
2. quando il file cambia, attende circa 30 secondi per evitare letture ripetute durante una scrittura;
3. confronta Quest ID + contentHash con il proprio stato locale;
4. prepara solo record nuovi o modificati;
5. limita gli upload a un massimo indicativo di un batch ogni 5 minuti;
6. se non ci sono novità, non effettua richieste inutili.

Come fallback, il Companion può ricontrollare il file ogni 5 minuti se il file watcher non è disponibile.

Importante: le SavedVariables vengono normalmente scritte su disco durante logout, uscita o `/reload`. Il Companion quindi non deve aspettarsi dati nuovi in tempo reale mentre WoW non ha ancora scritto il file.

## Silenziosità

Dopo la prima configurazione:

- nessun popup continuo;
- nessuna conferma per ogni invio;
- nessun messaggio nella chat di WoW;
- eventuali errori del Companion restano nella sua interfaccia/log, non nell'addon.

## Privacy

Il backend dovrebbe ricevere soltanto i campi necessari alla localizzazione e alla deduplicazione.

Prima dell'implementazione del Companion devono essere definiti:

- endpoint;
- formato payload;
- conservazione dati;
- cancellazione/disattivazione;
- versione privacy notice;
- controllo finale delle regole Blizzard e dei termini applicabili ai software esterni.

## Regola di conformità

Il Companion non è un mezzo per superare i limiti delle API addon.

Legge esclusivamente dati che ForeverITA ha già ottenuto attraverso le API/eventi consentiti e che WoW ha scritto nelle SavedVariables.

Prima di distribuirlo, va comunque rifatta una verifica delle regole Blizzard aggiornate per software esterno.
