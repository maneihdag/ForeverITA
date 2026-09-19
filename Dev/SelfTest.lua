local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local SelfTest = {}
FIT.SelfTest = SelfTest

local function equal(actual, expected)
    return actual == expected
end

function SelfTest:Run()
    if not FIT.Data then
        FIT:Print("SELFTEST FAIL: DataRegistry non disponibile.")
        return false
    end

    local passed, failed = 0, 0

    local function check(name, condition)
        if condition then
            passed = passed + 1
            FIT:Print("SELFTEST PASS: " .. name)
        else
            failed = failed + 1
            FIT:Print("SELFTEST FAIL: " .. name)
        end
    end

    local classic, classicSource = FIT.Data:ResolveQuest(990000001, "classic")
    check("Classic fixture trovata", classic ~= nil and classicSource == "classic")
    check("Classic title", classic and equal(classic.title, "[TEST] Base Classic"))

    local forever, foreverSource = FIT.Data:ResolveQuest(990000001, "forever")
    check("Forever override applicato", forever ~= nil and foreverSource == "forever_override")
    check("Forever title prevale", forever and equal(forever.title, "[TEST] Override Forever"))
    check(
        "Campo non sovrascritto resta Classic",
        forever and equal(forever.objectives, "Verifica il fallback dei campi non sovrascritti.")
    )

    local foreverOnly, foreverOnlySource = FIT.Data:ResolveQuest(990000002, "forever")
    check("Forever-only disponibile", foreverOnly ~= nil and foreverOnlySource == "forever")

    local classicNoForeverOnly = FIT.Data:ResolveQuest(990000002, "classic")
    check("Forever-only assente su Classic", classicNoForeverOnly == nil)

    local missing, missingSource = FIT.Data:ResolveQuest(990000003, "forever")
    check("Quest sconosciuta resta missing", missing == nil and missingSource == "missing")

    FIT:Print(string.format("SELFTEST: %d pass, %d fail", passed, failed))
    return failed == 0
end
