# Linee guida traduzione ForeverITA

Aggiornato: 2026-09-20.

## Regola generale

Le traduzioni di prova devono essere leggibili in italiano senza inventare terminologia ufficiale che non è stata verificata.

## Terminologia

Ordine di priorità:

1. terminologia italiana ufficiale Blizzard verificata;
2. traduzione italiana coerente e prudente;
3. nome originale inglese quando il termine proprio o il nome oggetto non è ancora verificato.

Esempio già verificato:

- Thunder Bluff → Picco del Tuono.

Mulgore resta Mulgore.

## Nomi propri

NPC, località minori e nomi di oggetti restano in inglese finché non abbiamo una fonte italiana affidabile.

Questo evita di creare nomi italiani arbitrari difficili da riconoscere in gioco.

## Placeholder giocatore

Nei dati di traduzione usare:

`<PLAYER>`

La UI futura potrà decidere se sostituirlo con il nome del personaggio solo al momento della visualizzazione.

Il database e il collector non devono conservare il nome reale del giocatore.

## Stato dei record

Durante il prototipo i record reali usano:

`status = "manual_test_translation"`

Non significa traduzione definitiva.

Prima di una release pubblica serviranno revisione terminologica e controllo qualità.

## Provenienza

Ogni record reale deve indicare almeno:

- client sorgente;
- build sorgente;
- hash dei campi originali quando disponibili;
- eventuale nota terminologica.

## Classic e Forever

Una traduzione Classic può diventare base per Forever, ma non viene considerata verificata su Forever finché non viene confrontata sul client reale.
