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

local FRAME_WIDTH = 410
local MIN_HEIGHT = 230
local MAX_HEIGHT = 520
local TEXT_WIDTH = 344

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

local function addBorder(frame)
    local top = frame:CreateTexture(nil, "BORDER")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(1)
    top:SetColorTexture(0.45, 0.37, 0.12, 0.75)

    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
    bottom:SetColorTexture(0.45, 0.37, 0.12, 0.75)

    local left = frame:CreateTexture(nil, "BORDER")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(1)
    left:SetColorTexture(0.45, 0.37, 0.12, 0.75)

    local right = frame:CreateTexture(nil, "BORDER")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(1)
    right:SetColorTexture(0.45, 0.37, 0.12, 0.75)
end

function TranslationUI:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(FRAME_WIDTH, 360)
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
    bg:SetColorTexture(0.025, 0.025, 0.025, 0.94)

    addBorder(frame)

    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 18, -15)
    heading:SetText("ForeverITA")
    frame.heading = heading

    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("LEFT", heading, "RIGHT", 8, 0)
    subtitle:SetText("· Traduzione italiana")
    frame.subtitle = subtitle

    local source = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    source:SetPoint("TOPLEFT", 18, -40)
    source:SetPoint("TOPRIGHT", -42, -40)
    source:SetJustifyH("LEFT")
    source:SetTextColor(0.65, 0.65, 0.65)
    frame.source = source

    local close = CreateFrame("Button", nil, frame)
    close:SetSize(28, 28)
    close:SetPoint("TOPRIGHT", -7, -7)

    local closeText = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetAllPoints()
    closeText:SetText("×")

    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -58)
    scroll:SetPoint("BOTTOMRIGHT", -31, 18)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(TEXT_WIDTH, 1)
    scroll:SetScrollChild(child)

    local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetWidth(TEXT_WIDTH)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetSpacing(4)
    text:SetWordWrap(true)

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
        frame:SetPoint("TOPLEFT", _G.QuestFrame, "TOPRIGHT", 10, 0)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 220, 0)
    end
end

function TranslationUI:ShowQuest(questID, record, sourceName, eventName)
    if type(record) ~= "table" then
        return
    end

    local frame = self:Create()
    self:Anchor(frame)

    local flavor = FIT.Compat.Client and FIT.Compat.Client:GetDataFlavor() or "unknown"

    if flavor == "forever" and sourceName == "classic" then
        frame.source:SetText("Base Classic · DA VERIFICARE SU FOREVER")
    elseif sourceName == "forever" or sourceName == "forever_override" or sourceName == "forever_replace" then
        frame.source:SetText("Dati verificati per Forever")
    else
        frame.source:SetText("")
    end

    local parts = {}
    addSection(parts, nil, record.title)

    if eventName == "QUEST_DETAIL" then
        addSection(parts, "Descrizione", record.description)
        addSection(parts, "Obiettivi", record.objectives)
    elseif eventName == "QUEST_PROGRESS" then
        addSection(parts, "In corso", record.progress)
    elseif eventName == "QUEST_COMPLETE" then
        addSection(parts, "Completamento", record.completion)
    else
        addSection(parts, "Descrizione", record.description)
        addSection(parts, "Obiettivi", record.objectives)
        addSection(parts, "In corso", record.progress)
        addSection(parts, "Completamento", record.completion)
    end

    frame.text:SetHeight(2000)
    frame.text:SetText(table.concat(parts))

    local textHeight = frame.text:GetStringHeight()
    local contentHeight = math.max(textHeight + 16, 80)
    local targetHeight = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, contentHeight + 86))

    frame:SetHeight(targetHeight)
    frame.child:SetHeight(math.max(contentHeight, frame.scroll:GetHeight()))
    frame.text:SetHeight(contentHeight)

    frame.scroll:SetVerticalScroll(0)
    frame:Show()
end

function TranslationUI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end
