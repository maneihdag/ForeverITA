local addonName, private = ...

local FIT = private
if type(FIT) ~= "table" then
    FIT = _G.ForeverITA_NS
end
if type(FIT) ~= "table" then
    return
end

FIT.Compat = FIT.Compat or {}

local UI = {
    testWindow = nil,
}

FIT.Compat.UI = UI

function UI:CreateTestWindow()
    if self.testWindow then
        return self.testWindow
    end

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(420, 160)
    frame:SetPoint("CENTER")
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

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.88)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("ForeverITA - test UI")

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", 24, -58)
    body:SetPoint("TOPRIGHT", -24, -58)
    body:SetJustifyH("LEFT")
    body:SetText(
        "Se vedi questa finestra, il test UI di base funziona su questo client.\n\n" ..
        "Classic Era: banco di prova.\n" ..
        "WoW Forever: DA TESTARE."
    )

    local close = CreateFrame("Button", nil, frame)
    close:SetSize(80, 24)
    close:SetPoint("BOTTOM", 0, 16)

    local closeText = close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetAllPoints()
    closeText:SetText("Chiudi")

    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame:Hide()
    self.testWindow = frame
    return frame
end

function UI:ToggleTestWindow()
    local frame = self:CreateTestWindow()

    if frame:IsShown() then
        frame:Hide()
        FIT:Print("Finestra test UI chiusa.")
    else
        frame:Show()
        FIT:Print("Finestra test UI aperta.")
    end
end
