local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" or not FIT.Data then
    return
end

-- Override sintetico della fixture Classic. Il campo objectives deve continuare
-- a provenire dal livello Classic, dimostrando il merge per campo.
FIT.Data:RegisterQuest("forever", 990000001, {
    title = "[TEST] Override Forever",
    description = "Record sintetico usato per verificare la precedenza Forever.",
    _meta = {
        synthetic = true,
        provenance = "ForeverITA internal test fixture",
    },
})

-- Quest sintetica presente soltanto nel livello Forever.
FIT.Data:RegisterQuest("forever", 990000002, {
    title = "[TEST] Solo Forever",
    description = "Record sintetico senza base Classic.",
    objectives = "Verifica la risoluzione di una quest Forever-only.",
    _mode = "replace",
    _meta = {
        synthetic = true,
        provenance = "ForeverITA internal test fixture",
    },
})
