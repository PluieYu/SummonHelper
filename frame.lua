---
--- https://github.com/PluieYu/G_SummonHelper?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/14 21:25
---
--
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")

SummonHelperFrame = {}
function SummonHelperFrame:SetupFrame()
    if frame then return end
    frame = CreateFrame("Frame", "SummonHelperFrame", UIParent)
    -- size
    local width = 200
    local height = 200
    frame:SetWidth(width)
    frame:SetHeight(height)

    -- background
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1,
        edgeFile = "Interface\\AddOns\\G_SummonHelper\\Textures\\border", edgeSize = 32,
        insets = {left = 1, right = 1, top = 20, bottom = 1},
    })
    frame:SetBackdropColor(24/255, 24/255, 24/255)
    frame:SetBackdropBorderColor(0/255, 0/255, 255/255)
    frame:SetFrameStrata("LOW")

    -- position
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    -- drag and drop
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true) -- can't move it outside of the screen
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        self:SaveFramePosition()
    end)



    ---- auto button
    --frame.autoButton = self:CreateButton(
    --        frame, 20,14, -40, -15, "TOPRIGHT",
    --        function()
    --            SummonHelper:LevelDebug(2, format("autoSummon start"))
    --            SummonHelper:autoSummon()
    --        end
    --)
    --frame.autoButton.texture= self:CreateButtontexture(
    --        frame.autoButton,"ARTWORK ","Interface\\AddOns\\SummonHelper\\Textures\\Armory", 0,1,0,1)


    -- announce button
    frame.announceButton = self:CreateButton(
            frame, 20,14, -20, -15, "TOPRIGHT",
            function()
                local playerZone = SummonHelper:GetZone("player")
                local chatType = "PARTY"
                if GetNumRaidMembers() > 0 then
                    chatType = "RAID"
                end
                SendChatMessage(string.format(self:BuildMessage(L["团队打字打关键词被拉到 %s"]), playerZone ), chatType)
            end
    )
    frame.announceButton.texture= self:CreateButtontexture(
            frame.announceButton,"ARTWORK ","Interface\\AddOns\\G_SummonHelper\\Textures\\report", 0,1,0,1)


    -- close button
    frame.closeButton = self:CreateButton(
            frame, 20,14, 0, -15, "TOPRIGHT", function() frame:Hide() end )
    frame.closeButton.texture = self:CreateButtontexture(
            frame.closeButton,"ARTWORK","Interface\\AddOns\\G_SummonHelper\\Textures\\close", 0,1,0,1)

    frame.header = frame:CreateFontString(nil, "OVERLAY")
    frame.header:SetWidth(width)
    frame.header:SetHeight(15)
    frame.header:SetPoint("TOP", frame, "TOP", 5, -14)
    frame.header:SetFont(L["font"], 12)
    frame.header:SetJustifyH("LEFT")
    frame.header:SetText(SummonHelper.Prefix)
    frame.header:SetShadowOffset(.8, -.8)
    frame.header:SetShadowColor(0, 0, 0, 1)

    --frame.body = SummonHelperFrame:CreateBody(frame, height)
    frame.body = CreateFrame("Frame", nil, frame)
    frame.body:Show()
    frame.body:SetWidth(width)
    frame.body:SetHeight(height)
    frame.body:ClearAllPoints()
    frame.body:SetPoint("TOP", frame, "TOP", 0, -32)

    frame.Candidate = {}
    for i=1, 5 do
        frame.Candidate["player"..i] = self:SetupCandidateFrame(frame, i + 2, "")
    end

    local x = SummonHelper.opt.xOfs
    local y = SummonHelper.opt.yOfs
    local point = SummonHelper.opt.point
    local relativePoint = SummonHelper.opt.relativePoint
    if x and y then
        frame:ClearAllPoints()
        frame:SetPoint(point, UIParent, relativePoint, x  , y )
    else
        self:ResetFramePosition()
    end
    self.frame = frame
end
function SummonHelperFrame:SetupCandidateFrame(parent, position)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("LOW")
    local height = 20
    local ButtonWidth = 20
    local ButtonHeight = 20
    -- size
    frame:SetWidth(parent:GetWidth())
    frame:SetHeight(height)

    -- background
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
        insets = {left = 1, right = 1, top = 0, bottom = 1},
    })
    frame:SetBackdropColor(38/255, 171/255, 71/255)

    -- position
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0 - (position - 1) * height)

    -- drag and drop
    frame:SetMovable(false)

    -- player name
    local text = frame:CreateFontString(nil, "ARTWORK")
    text:SetParent(frame)
    text:ClearAllPoints()
    text:SetWidth(parent:GetWidth() - ButtonWidth -ButtonWidth)
    text:SetHeight(height)
    text:SetPoint("Left", frame, "LEFT", 22, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("CENTER")
    text:SetFont(L["font"], 12)
    text:SetText("N/A")
    frame.text = text
    frame:Hide()

    frame.removeButton = SummonHelperFrame:CreateButton(
            frame, ButtonWidth,ButtonHeight, 1, 0, "TOPLEFT",
            function()
                targetName = text:GetText()
                SummonHelper:OnCommReceive("","","","Remove",targetName)
                SummonHelper:RemoveFonc(targetName)
            end
    )
    frame.removeButton.texture = SummonHelperFrame:CreateButtontexture(
            frame.removeButton,"OVERLAY", "Interface\\Icons\\spell_chargenegative",
            0.08, 0.92, 0.08, 0.92)

    frame.summonButton =  SummonHelperFrame:CreateButton(
            frame, ButtonWidth,ButtonHeight, 0, 0, "TOPRIGHT",
            function()
                targetName = text:GetText()
                SummonHelper:SummonFonc(targetName)
            end
    )
    frame.summonButton.texture = SummonHelperFrame:CreateButtontexture(
            frame.summonButton,"OVERLAY", "Interface\\Icons\\spell_shadow_twilight",
            0.08, 0.92, 0.08, 0.92)

    return frame

end

function SummonHelperFrame:CreateButtontexture(parent,TextureDrawLayer,texturePath, Coord1,Coord2,Coord3,Coord4)
    local texture = parent:CreateTexture(nil, TextureDrawLayer)
    texture:SetAllPoints(parent)
    texture:SetTexture(texturePath)
    texture:SetTexCoord(Coord1, Coord2, Coord3, Coord4) -- zoom in to hide border
    parent:SetHighlightTexture(texturePath)
    return texture
end
function SummonHelperFrame:CreateButton(parent, Width, Height, posX, posY, Directtion, func)
    local button = CreateFrame("Button", "", parent)
    button:Show()
    button:SetPoint(Directtion, posX, posY)
    button:SetWidth(Width)
    button:SetHeight(Height)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    if func then
        button:SetScript("OnClick", func)
    end
    return button
end

function SummonHelperFrame:ResetFramePosition()
    if not frame then
        self:SetupFrame()
    end
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    SummonHelper.opt.posx = nil
    SummonHelper.opt.posy = nil
    SummonHelper.opt.point = "CENTER"
    SummonHelper.opt.relativePoint = "CENTER"
end

function SummonHelperFrame:SaveFramePosition()
    if not frame then
        self:SetupFrame()
    end
    point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    SummonHelper.opt.point = point
    SummonHelper.opt.relativePoint = relativePoint
    SummonHelper.opt.xOfs = xOfs
    SummonHelper.opt.yOfs = yOfs
end



