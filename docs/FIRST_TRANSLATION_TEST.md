# Prima prova reale di traduzione

Aggiornato: 2026-09-20.

## Obiettivo

Verificare su WoW Classic Era che ForeverITA sappia:

1. trovare una quest presente nel database italiano;
2. distinguere la traduzione Classic da un futuro override Forever;
3. mostrare la traduzione italiana in una finestra separata;
4. lasciare il collector silenzioso;
5. non modificare direttamente i frame protetti del client.

## Quest di prova

Quest ID: 757 — Rite of Strength

Traduzione ForeverITA:

- titolo: Rito della Forza;
- descrizione: traduzione manuale;
- obiettivi: traduzione manuale.

Il testo sorgente è stato osservato sul client Classic Era 1.15.9 build 69722.

Per la prima prova, nomi propri non verificati in italiano restano in inglese. "Thunder Bluff" viene reso come "Picco del Tuono", terminologia italiana verificata.

## UI

ForeverITA usa una finestra propria, separata dalla QuestFrame Blizzard.

Su Classic, se QuestFrame è visibile, il pannello viene posizionato accanto alla finestra quest.

Comando di prova:

`/fit show 757`

Quando la quest 757 viene aperta nel normale dialogo di gioco, la traduzione dovrebbe apparire automaticamente.

La finestra si chiude quando termina/cambia il dialogo quest tramite `QUEST_FINISHED`.

## Compatibilità

- CreateFrame: supportato su Classic Era.
- QUEST_FINISHED: documentato su Classic Era.
- UIPanelScrollFrameTemplate: usato nel livello Compat e da verificare direttamente in gioco.
- Tutto il comportamento resta DA TESTARE SU FOREVER.
