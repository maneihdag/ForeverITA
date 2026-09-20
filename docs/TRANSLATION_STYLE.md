# Linee guida traduzione ForeverITA

Aggiornato: 2026-09-20.

## Regola generale

Le traduzioni di prova devono essere leggibili in italiano senza inventare terminologia ufficiale che non è stata verificata.

## Terminologia

Il glossario dei termini già verificati è in `docs/GLOSSARY_IT.md`.

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

## Stati traduzione v0.1

Per evitare che il livello dati venga confuso con una verifica reale sul client, `_meta.status` ha un significato esplicito.

Valori previsti per i nuovi record:

- `draft` — traduzione preparata ma non revisionata;
- `reviewed` — testo revisionato, ma non necessariamente provato in gioco;
- `verified_classic` — traduzione e comportamento verificati sul client Classic usato come laboratorio;
- `verified_forever` — traduzione verificata direttamente sul client WoW Forever.

`manual_test_translation` resta temporaneamente accettato per i quattro record del prototipo già presenti. Il futuro validator dovrà segnalarlo come stato legacy/warning, non come errore, finché quei record non vengono migrati.

Essere nel layer `Forever_it` NON significa automaticamente `verified_forever`.

## Regola etichette UI

La UI non deve dichiarare che un dato è verificato su Forever soltanto perché proviene dal layer Forever.

Regola prevista:

- Forever + fallback Classic → `Base Classic · DA VERIFICARE SU FOREVER`;
- Forever + override con `status = verified_forever` → `Verificata su Forever`;
- Forever + override con qualunque altro stato → `Override Forever · DA VERIFICARE`;
- Classic → nessuna etichetta tecnica durante il normale utilizzo.

Stato implementazione: **DA PASSARE A CODEX DOMANI**.

## Campi sorgente dinamici

Il client può sostituire token del testo quest prima che l'addon lo legga.

Casi confermati:

- Quest 755 usa `<class>` nel template; sul personaggio del test Classic il collector ha ricevuto `shaman`;
- Quest 747 usa `<race>` e `<name>` nel completion; il collector del personaggio Tauren ha ricevuto `tauren` e il nome reale prima del privacy scrub.

Per questi casi il record può dichiarare:

```lua
_dynamicFields = {
    description = { "class" },
}
```

Valori previsti inizialmente:

- `class`;
- `race`.

Il nome giocatore resta gestito separatamente dal placeholder `<PLAYER>` perché è anche una regola di privacy.

Un campo marcato dinamico non deve generare automaticamente `modified` soltanto perché un altro personaggio vede una sostituzione diversa.

Non fare sostituzioni globali ingenue di parole come `shaman` o `tauren`: potrebbero essere testo narrativo reale e non placeholder.
