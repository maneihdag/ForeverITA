# Riferimenti e licenze di terze parti

Aggiornato: 2026-09-20.

Questo documento serve a distinguere ciò che possiamo studiare da ciò che possiamo eventualmente riutilizzare.

| Progetto | Uso previsto | Licenza verificata | Regola ForeverITA |
| --- | --- | --- | --- |
| Daribon/QuestTranslator | Struttura traduzione quest, eventi, UI parallela | Nessuna licenza dichiarata nel repository | Solo studio/riferimento |
| leoaviana/QuestTradutor | Quest, gossip, tooltip, separazione dati | Nessuna licenza dichiarata nel repository | Solo studio/riferimento |
| Questie/Questie | Architettura modulare, database, validation | Nessuna licenza globale dichiarata via metadata GitHub; vari componenti hanno licenze proprie | Solo studio finché la licenza non è chiarita per il file specifico |
| cleanuplater/cmangos-vanilla-db-localized | Dati localizzati Vanilla, incluso `Translations/Italian/Italian_Quest.sql` | Nessuna licenza dichiarata nel repository | Studio/confronto; non importare automaticamente |
| cmangos/classic-db | Schema/dati Vanilla upstream | GPL-3.0 per il repository; README/COPYRIGHT separano esplicitamente i materiali WoW dalla GPL | Studio e validazione; non trattare automaticamente i testi di gioco come GPL |
| anombyte93/ForeverDiffCollector | Collector Forever, eventi quest, SavedVariables | MIT | Riutilizzo possibile con attribuzione, ma nessun codice è stato copiato nella v0.0.2 |
| Skold177/ForeverTome | Raccolta dati Forever e profilo quest moderno | GPL-2.0 | Studio; non copiare nel core senza decisione licenza |
| IrcDirk/Carbonite-All-in-One-Retail-Classic | Compatibilità Camelot/Forever, quest capture | GPL-3.0 | Studio; non copiare nel core senza decisione licenza |
| Tacit-Labs/Horizon-Suite | Capability detection e osservazioni beta | MIT | Studio; eventuale riuso solo con attribuzione |
| wowaddonmaker/classicuiforever | UI reale su Forever | Licenza GitHub: Other/NOASSERTION | Solo studio finché i termini non sono chiari |

## Osservazioni

La presenza di una licenza open source sul codice non concede automaticamente diritti sui testi, asset o altri contenuti di World of Warcraft.

ForeverITA deve tenere separata la provenienza del codice dalla provenienza dei dati di traduzione.


## Filtro tecnico obbligatorio

Anche se un progetto ha una licenza compatibile, ForeverITA non integra automaticamente soluzioni che richiedono:

- DLL;
- injection;
- lettura memoria;
- modifica del client;
- bot o automazione;
- estrazione dati fuori dalle API addon.

La licenza e la conformità tecnica sono due controlli separati.

Se un progetto usa metodi non chiari, resta solo un riferimento finché il funzionamento non viene verificato.

## Verifica del 20 settembre 2026

Sono stati ricontrollati i repository di riferimento.

Punti utili:

- `Daribon/QuestTranslator` contiene un grande database italiano e usa una finestra di traduzione separata, ma non dichiara una licenza repository: resta solo riferimento.
- `leoaviana/QuestTradutor` separa quest, gossip e tooltip in file dati distinti: utile come esempio storico di separazione, non come codice da copiare.
- `Questie` mantiene strumenti di validation e test del database: rafforza la scelta di introdurre un validator ForeverITA prima di scalare i dati.
- `ForeverDiffCollector` usa un collector event-driven e limitato con `11509, 16001`: conferma la fattibilità pratica del modello, senza provare automaticamente la compatibilità di ForeverITA.
- `CMaNGOS Vanilla DB Localized` possiede effettivamente un file italiano delle quest; l'assenza di una licenza chiara impedisce l'import massivo diretto.
