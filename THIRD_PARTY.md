# Riferimenti e licenze di terze parti

Aggiornato: 2026-09-20.

Questo documento serve a distinguere ciò che possiamo studiare da ciò che possiamo eventualmente riutilizzare.

| Progetto | Uso previsto | Licenza verificata | Regola ForeverITA |
| --- | --- | --- | --- |
| Daribon/QuestTranslator | Struttura traduzione quest, eventi, UI parallela | Nessuna licenza dichiarata nel repository | Solo studio/riferimento |
| leoaviana/QuestTradutor | Quest, gossip, tooltip, separazione dati | Nessuna licenza dichiarata nel repository | Solo studio/riferimento |
| Questie/Questie | Architettura modulare, database, validation | Nessuna licenza repository chiaramente dichiarata via metadata GitHub | Solo studio finché la licenza non è chiarita per il file specifico |
| cleanuplater/cmangos-vanilla-db-localized | Dati localizzati Vanilla | Nessuna licenza dichiarata nel repository | Non importare automaticamente |
| cmangos/classic-db | Schema/dati Vanilla upstream | GPL-3.0 per il repository; i contenuti di gioco possono avere diritti separati | Studio e validazione; import dati solo dopo revisione specifica |
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
