local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" or not FIT.Data then
    return
end

-- Fixture sintetica: NON è una quest Blizzard e non è contenuto di gioco.
-- Serve solo a verificare il resolver Classic -> Forever senza importare dati esterni.
FIT.Data:RegisterQuest("classic", 990000001, {
    title = "[TEST] Base Classic",
    description = "Record sintetico usato per testare il livello dati Classic.",
    objectives = "Verifica il fallback dei campi non sovrascritti.",
    _meta = {
        synthetic = true,
        provenance = "ForeverITA internal test fixture",
    },
})
