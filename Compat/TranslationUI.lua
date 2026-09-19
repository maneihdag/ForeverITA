local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local TranslationUI = {
    frame = nil,
}

FIT.Compat.TranslationUI = TranslationUI

local function addSection(parts, heading, text)
    if type(text) ~= "string" or text == "" then
        return
    end

    if #parts > 0 then
        parts[#parts + 1] = "\n\n"
    end

    if heading then
        parts[#parts + 1] = "|cffffd200" .. heading .. "|r\n"
    end

    parts[#parts + 1] = text
end

function TranslationUI:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(470, 520)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.035, 0.035, 0.035, 0.96)

    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 20, -16)
    heading:SetText("ForeverITA — Traduzione italiana")
    frame.heading = heading

    local source = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    source:SetPoint("TOPLEFT", 20, -42)
    source:SetPoint("TOPRIGHT", -45, -42)
    source:SetJustifyH("LEFT")
    frame.source = source

    local close = CreateFrame("Button", nil, frame)
    close:SetSize(28, 28)
    close:SetPoint("TOPRIGHT", -10, -10)

    local closeText = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetAllPoints()
    closeText:SetText("×")

    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, -68)
    scroll:SetPoint("BOTTOMRIGHT", -34, 20)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(400, 1)
    scroll:SetScrollChild(child)

    local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetPoint("TOPRIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetSpacing(4)

    frame.scroll = scroll
    frame.child = child
    frame.text = text

    frame:Hide()
    self.frame = frame
    return frame
end

function TranslationUI:Anchor(frame)
    frame:ClearAllPoints()

    if _G.QuestFrame and _G.QuestFrame.IsShown and _G.QuestFrame:IsShown() then
        frame:SetPoint("TOPLEFT", _G.QuestFrame, "TOPRIGHT", 12, 0)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 260, 0)
    end
end

function TranslationUI:ShowQuest(questID, record, sourceName)
    if type(record) ~= "table" then
        return
    end

    local frame = self:Create()
    self:Anchor(frame)

    local flavor = FIT.Compat.Client and FIT.Compat.Client:GetDataFlavor() or "unknown"
    local sourceText

    if flavor == "forever" and sourceName == "classic" then
        sourceText = "Quest " .. tostring(questID) .. " · Base Classic — da verificare su Forever"
    elseif sourceName == "forever" or sourceName == "forever_override" or sourceName == "forever_replace" then
        sourceText = "Quest " .. tostring(questID) .. " · Dati Forever"
    else
        sourceText = "Quest " .. tostring(questID) .. " · Base Classic"
    end

    frame.source:SetText(sourceText)

    local parts = {}
    addSection(parts, nil, record.title)
    addSection(parts, "Descrizione", record.description)
    addSection(parts, "Obiettivi", record.objectives)
    addSection(parts, "In corso", record.progress)
    addSection(parts, "Completamento", record.completion)

    frame.text:SetText(table.concat(parts))

    local height = math.max(frame.text:GetStringHeight() + 24, frame.scroll:GetHeight())
    frame.child:SetHeight(height)

    frame.scroll:SetVerticalScroll(0)
    frame:Show()
end

function TranslationUI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end
