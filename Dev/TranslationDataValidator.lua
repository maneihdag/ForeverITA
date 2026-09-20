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

local VALID_RECORD_KEYS = {
    title = true,
    description = true,
    objectives = true,
    progress = true,
    completion = true,
    _mode = true,
    _sourceHashes = true,
    _dynamicFields = true,
    _meta = true,
}

local VALID_META_KEYS = {
    synthetic = true,
    status = true,
    sourceClient = true,
    sourceBuild = true,
    terminologyNote = true,
    provenance = true,
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

local function validateKnownKeys(layer, questID, record, errors)
    for key in pairs(record) do
        if not VALID_RECORD_KEYS[key] then
            addIssue(errors, layer, questID, "campo record non riconosciuto: " .. tostring(key))
        end
    end

    local meta = record._meta
    if meta ~= nil and type(meta) ~= "table" then
        addIssue(errors, layer, questID, "_meta deve essere una table")
        return
    end

    if type(meta) == "table" then
        for key, value in pairs(meta) do
            if not VALID_META_KEYS[key] then
                addIssue(errors, layer, questID, "_meta." .. tostring(key) .. " non è riconosciuto")
            elseif key == "synthetic" and type(value) ~= "boolean" then
                addIssue(errors, layer, questID, "_meta.synthetic deve essere boolean")
            elseif key ~= "synthetic" and not isNonEmptyString(value) then
                addIssue(errors, layer, questID, "_meta." .. tostring(key) .. " deve essere una stringa non vuota")
            end
        end
    end
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
        elseif layer == "classic" and not isNonEmptyString(record[field]) then
            addIssue(errors, layer, questID, "_dynamicFields." .. tostring(field) .. " richiede il campo tradotto")
        elseif type(tokens) ~= "table" or next(tokens) == nil then
            addIssue(errors, layer, questID, "_dynamicFields." .. tostring(field) .. " deve contenere almeno un token")
        else
            local seen = {}
            local count = 0
            local maxIndex = 0

            for key, token in pairs(tokens) do
                if type(key) ~= "number"
                    or key < 1
                    or math.floor(key) ~= key then
                    addIssue(
                        errors,
                        layer,
                        questID,
                        "_dynamicFields." .. tostring(field) .. " deve essere una lista numerica"
                    )
                else
                    count = count + 1
                    if key > maxIndex then
                        maxIndex = key
                    end
                end

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

            if count ~= maxIndex then
                addIssue(
                    errors,
                    layer,
                    questID,
                    "_dynamicFields." .. tostring(field) .. " deve essere una lista continua senza buchi"
                )
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
    if record._mode == nil then
        return
    end

    if layer ~= "forever" then
        addIssue(errors, layer, questID, "_mode è ammesso soltanto nel layer forever")
        return
    end

    if record._mode ~= "replace" and record._mode ~= "remove" then
        addIssue(errors, layer, questID, "_mode deve essere replace oppure remove")
        return
    end

    if record._mode == "remove" then
        for _, field in ipairs(TEXT_FIELDS) do
            if record[field] ~= nil then
                addIssue(errors, layer, questID, "_mode remove non deve contenere " .. field)
            end
        end
        if record._sourceHashes ~= nil then
            addIssue(errors, layer, questID, "_mode remove non deve contenere _sourceHashes")
        end
        if record._dynamicFields ~= nil then
            addIssue(errors, layer, questID, "_mode remove non deve contenere _dynamicFields")
        end
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
        return
    end

    if not VALID_STATUS[status] then
        addIssue(errors, layer, questID, "_meta.status non riconosciuto: " .. tostring(status))
        return
    end

    if meta.synthetic == true then
        return
    end

    if layer == "classic" and status == "verified_forever" then
        addIssue(errors, layer, questID, "verified_forever non è valido nel layer classic")
    elseif layer == "forever" and status == "verified_classic" then
        addIssue(errors, layer, questID, "verified_classic non è valido nel layer forever")
    end

    if status == "verified_forever" then
        if not isNonEmptyString(meta.sourceClient) then
            addIssue(errors, layer, questID, "verified_forever richiede _meta.sourceClient")
        end
        if not isNonEmptyString(meta.sourceBuild) then
            addIssue(errors, layer, questID, "verified_forever richiede _meta.sourceBuild")
        end
    end
end

local function validateCurrentHashSchema(layer, questID, record, errors)
    if type(record._sourceHashes) ~= "table"
        or not FIT.RecordFormat
        or type(FIT.RecordFormat.schema) ~= "number" then
        return
    end

    local prefix = "^f" .. tostring(FIT.RecordFormat.schema) .. "%-"
    for field, value in pairs(record._sourceHashes) do
        if TEXT_FIELD_SET[field]
            and type(value) == "string"
            and not value:match(prefix) then
            addIssue(
                errors,
                layer,
                questID,
                "_sourceHashes." .. tostring(field)
                    .. " usa uno schema diverso da RecordFormat "
                    .. tostring(FIT.RecordFormat.schema)
            )
        end
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

local function validateForeverReal(layer, questID, record, errors)
    if record._mode == "remove" then
        return
    end

    local hasTranslation = false
    for _, field in ipairs(TEXT_FIELDS) do
        if isNonEmptyString(record[field]) then
            hasTranslation = true
            break
        end
    end

    local hasSourceHashes = type(record._sourceHashes) == "table"
        and next(record._sourceHashes) ~= nil
    local hasDynamicFields = type(record._dynamicFields) == "table"
        and next(record._dynamicFields) ~= nil
    local verifiedMetadataOnly = type(record._meta) == "table"
        and record._meta.status == "verified_forever"

    if not hasTranslation
        and not hasSourceHashes
        and not hasDynamicFields
        and not verifiedMetadataOnly then
        addIssue(errors, layer, questID, "override Forever non-remove senza contenuto utile")
    end
end

local function validateResolvedForever(questID, record, errors)
    if record._mode == "remove" then
        return
    end

    local resolved, source = FIT.Data:ResolveQuest(questID, "forever")
    if not resolved then
        addIssue(errors, "forever", questID, "override Forever non risolvibile: " .. tostring(source))
        return
    end

    local hasResolvedText = false
    for _, field in ipairs(TEXT_FIELDS) do
        if isNonEmptyString(resolved[field]) then
            hasResolvedText = true
            break
        end
    end

    if not hasResolvedText then
        addIssue(errors, "forever", questID, "override Forever non-remove senza testo tradotto risolto")
    end

    if type(resolved._dynamicFields) == "table" then
        for field in pairs(resolved._dynamicFields) do
            if TEXT_FIELD_SET[field] and not isNonEmptyString(resolved[field]) then
                addIssue(
                    errors,
                    "forever",
                    questID,
                    "_dynamicFields." .. tostring(field) .. " non ha un campo tradotto dopo il fallback"
                )
            end
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

    validateKnownKeys(layer, questID, record, errors)
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

    validateCurrentHashSchema(layer, questID, record, errors)

    if layer == "classic" then
        validateClassicReal(layer, questID, record, errors)
    elseif layer == "forever" then
        validateForeverReal(layer, questID, record, errors)
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

            if layer == "forever"
                and not (type(record._meta) == "table" and record._meta.synthetic == true) then
                validateResolvedForever(questID, record, errors)
            end
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
