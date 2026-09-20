local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

local Validator = {}
FIT.TranslationDataValidator = Validator

local TEXT_FIELDS = {
    "title",
    "description",
    "objectives",
    "progress",
    "completion",
}

local TEXT_FIELD_SET = {}
for _, field in ipairs(TEXT_FIELDS) do
    TEXT_FIELD_SET[field] = true
end

local BODY_FIELDS = {
    "description",
    "objectives",
    "progress",
    "completion",
}

local VALID_STATUS = {
    draft = true,
    reviewed = true,
    verified_classic = true,
    verified_forever = true,
}

local LEGACY_STATUS = {
    manual_test_translation = true,
}

local VALID_DYNAMIC_TOKEN = {
    class = true,
    race = true,
}

local function isNonEmptyString(value)
    return type(value) == "string" and value:match("%S") ~= nil
end

local function isValidQuestID(value)
    return type(value) == "number"
        and value > 0
        and math.floor(value) == value
end

local function addIssue(issues, layer, questID, message)
    issues[#issues + 1] = {
        layer = layer,
        questID = questID,
        message = message,
    }
end

local function validateHashes(layer, questID, record, errors)
    local hashes = record._sourceHashes
    if hashes == nil then
        return
    end

    if type(hashes) ~= "table" then
        addIssue(errors, layer, questID, "_sourceHashes deve essere una table")
        return
    end

    for field, value in pairs(hashes) do
        if not TEXT_FIELD_SET[field] then
            addIssue(errors, layer, questID, "_sourceHashes." .. tostring(field) .. " non è un campo noto")
        elseif type(value) ~= "string" or not value:match("^f%d+%-%d+$") then
            addIssue(errors, layer, questID, "_sourceHashes." .. tostring(field) .. " ha formato non valido")
        end
    end
end

local function validateDynamicFields(layer, questID, record, errors)
    local dynamicFields = record._dynamicFields
    if dynamicFields == nil then
        return
    end

    if type(dynamicFields) ~= "table" then
        addIssue(errors, layer, questID, "_dynamicFields deve essere una table")
        return
    end

    for field, tokens in pairs(dynamicFields) do
        if not TEXT_FIELD_SET[field] then
            addIssue(errors, layer, questID, "_dynamicFields." .. tostring(field) .. " non è un campo noto")
        elseif type(tokens) ~= "table" or #tokens == 0 then
            addIssue(errors, layer, questID, "_dynamicFields." .. tostring(field) .. " deve contenere almeno un token")
        else
            local seen = {}
            for _, token in ipairs(tokens) do
                if type(token) ~= "string" or not VALID_DYNAMIC_TOKEN[token] then
                    addIssue(
                        errors,
                        layer,
                        questID,
                        "_dynamicFields." .. tostring(field) .. " contiene token non valido: " .. tostring(token)
                    )
                elseif seen[token] then
                    addIssue(
                        errors,
                        layer,
                        questID,
                        "_dynamicFields." .. tostring(field) .. " contiene token duplicato: " .. tostring(token)
                    )
                else
                    seen[token] = true
                end
            end
        end
    end
end

local function validateTextFields(layer, questID, record, errors)
    for _, field in ipairs(TEXT_FIELDS) do
        local value = record[field]
        if value ~= nil and not isNonEmptyString(value) then
            addIssue(errors, layer, questID, field .. " deve essere una stringa non vuota")
        end
    end
end

local function validateMode(layer, questID, record, errors)
    if record._mode ~= nil
        and record._mode ~= "replace"
        and record._mode ~= "remove" then
        addIssue(errors, layer, questID, "_mode deve essere replace oppure remove")
    end
end

local function validateStatus(layer, questID, record, errors, warnings)
    local meta = record._meta
    if type(meta) ~= "table" then
        return
    end

    local status = meta.status
    if status == nil then
        return
    end

    if LEGACY_STATUS[status] then
        addIssue(warnings, layer, questID, "_meta.status usa il valore legacy " .. tostring(status))
    elseif not VALID_STATUS[status] then
        addIssue(errors, layer, questID, "_meta.status non riconosciuto: " .. tostring(status))
    end
end

local function validateClassicReal(layer, questID, record, errors)
    if not isNonEmptyString(record.title) then
        addIssue(errors, layer, questID, "title mancante o vuoto")
    end

    local hasBody = false
    for _, field in ipairs(BODY_FIELDS) do
        if isNonEmptyString(record[field]) then
            hasBody = true
            break
        end
    end
    if not hasBody then
        addIssue(errors, layer, questID, "manca almeno un campo tra description/objectives/progress/completion")
    end

    local meta = record._meta
    if type(meta) ~= "table" then
        addIssue(errors, layer, questID, "_meta mancante")
    else
        if not isNonEmptyString(meta.status) then
            addIssue(errors, layer, questID, "_meta.status mancante")
        end
        if not isNonEmptyString(meta.sourceClient) then
            addIssue(errors, layer, questID, "_meta.sourceClient mancante")
        end
        if not isNonEmptyString(meta.sourceBuild) then
            addIssue(errors, layer, questID, "_meta.sourceBuild mancante")
        end
    end

    if type(record._sourceHashes) ~= "table" then
        addIssue(errors, layer, questID, "_sourceHashes mancante")
        return
    end

    for _, field in ipairs(TEXT_FIELDS) do
        if record[field] ~= nil and record._sourceHashes[field] == nil then
            addIssue(errors, layer, questID, "_sourceHashes." .. field .. " mancante")
        end
    end
end

local function validateRecord(layer, questID, record, errors, warnings)
    if not isValidQuestID(questID) then
        addIssue(errors, layer, questID, "QuestID deve essere un intero positivo")
        return
    end

    if type(record) ~= "table" then
        addIssue(errors, layer, questID, "record deve essere una table")
        return
    end

    validateTextFields(layer, questID, record, errors)
    validateMode(layer, questID, record, errors)
    validateHashes(layer, questID, record, errors)
    validateDynamicFields(layer, questID, record, errors)
    validateStatus(layer, questID, record, errors, warnings)

    local synthetic = type(record._meta) == "table"
        and record._meta.synthetic == true

    if synthetic then
        return
    end

    if layer == "classic" then
        validateClassicReal(layer, questID, record, errors)
    end
end

function Validator:Run()
    if not FIT.Data or not FIT.Data.ForEachQuest then
        FIT:Print("DATATEST FAIL: DataRegistry/ForEachQuest non disponibile")
        return false
    end

    local errors = {}
    local warnings = {}
    local checked = 0

    for _, layer in ipairs({ "classic", "forever" }) do
        local ok, reason = FIT.Data:ForEachQuest(layer, function(questID, record)
            checked = checked + 1
            validateRecord(layer, questID, record, errors, warnings)
        end)

        if not ok then
            addIssue(errors, layer, 0, "impossibile iterare il layer: " .. tostring(reason))
        end
    end

    for _, issue in ipairs(errors) do
        FIT:Print(
            "DATATEST FAIL: "
                .. tostring(issue.layer)
                .. " quest "
                .. tostring(issue.questID)
                .. " - "
                .. tostring(issue.message)
        )
    end

    for _, issue in ipairs(warnings) do
        FIT:Print(
            "DATATEST WARN: "
                .. tostring(issue.layer)
                .. " quest "
                .. tostring(issue.questID)
                .. " - "
                .. tostring(issue.message)
        )
    end

    FIT:Print("DATATEST: " .. tostring(checked) .. " quest controllate")
    FIT:Print(
        "DATATEST: "
            .. tostring(#errors)
            .. " errori, "
            .. tostring(#warnings)
            .. " warning"
    )

    if #errors == 0 then
        FIT:Print("DATATEST PASS")
        return true
    end

    FIT:Print("DATATEST FAIL")
    return false
end
