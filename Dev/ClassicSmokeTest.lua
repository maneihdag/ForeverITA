local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local ClassicSmokeTest = {}
FIT.ClassicSmokeTest = ClassicSmokeTest

function ClassicSmokeTest:Run()
    local passed, failed, pending = 0, 0, 0

    local function pass(message)
        passed = passed + 1
        FIT:Print("CLASSIC PASS: " .. message)
    end

    local function fail(message)
        failed = failed + 1
        FIT:Print("CLASSIC FAIL: " .. message)
    end

    local function wait(message)
        pending = pending + 1
        FIT:Print("CLASSIC DA PROVARE: " .. message)
    end

    local Client = FIT.Compat.Client
    if Client and Client:GetDataFlavor() == "classic" then
        pass("Classic Era riconosciuto come ambiente di test.")
    else
        fail("Questo client non è stato riconosciuto come Classic Era.")
    end

    local state = Client and Client:GetState()
    if state and state.interface == 11509 then
        pass("Interface 11509 rilevata.")
    else
        wait("Interface attuale diversa da 11509: controllare /fit status.")
    end

    if FIT.Compat.Storage and FIT.Compat.Storage:IsReady() then
        pass("SavedVariables inizializzate.")
    else
        fail("SavedVariables non inizializzate.")
    end

    if FIT.Data and FIT.Data.ResolveQuest then
        pass("Motore dati caricato.")
    else
        fail("Motore dati non disponibile.")
    end

    if FIT.Compat.Quest and FIT.Compat.Quest.Read then
        pass("Compat quest caricato.")
    else
        fail("Compat quest non disponibile.")
    end

    if FIT.MissingQuestCollector then
        pass("Collector caricato.")
    else
        fail("Collector non disponibile.")
    end

    if FIT.QuestDebug and FIT.QuestDebug.seenEvents > 0 then
        pass("Almeno un evento quest è stato letto realmente.")
    else
        wait("Aprire una quest e poi rilanciare /fit classictest.")
    end

    wait("UI: usare /fit ui e controllare che la finestra sia visibile.")
    wait("Persistenza: /fit svtest start, /reload, /fit svtest check.")

    FIT:Print(
        string.format(
            "CLASSIC TEST: %d pass, %d fail, %d ancora da provare",
            passed,
            failed,
            pending
        )
    )
end
