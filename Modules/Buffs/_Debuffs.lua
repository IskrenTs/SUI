local Debuffs = SUI:NewModule("Buffs.Debuffs");

function Debuffs:OnEnable()
    if IsAddOnLoaded("BlizzBuffsFacade") then return end

    local db = SUI.db.profile.unitframes.buffs
    local theme = SUI.db.profile.general.theme

    -- DebuffType Colors for the Debuff Border
    local DebuffColor      = {}
    DebuffColor["none"]    = { r = 0.80, g = 0, b = 0 };
    DebuffColor["Magic"]   = { r = 0.20, g = 0.60, b = 1.00 };
    DebuffColor["Curse"]   = { r = 0.60, g = 0.00, b = 1.00 };
    DebuffColor["Disease"] = { r = 0.60, g = 0.40, b = 0 };
    DebuffColor["Poison"]  = { r = 0.00, g = 0.60, b = 0 };

    local function UpdateDuration(self, timeLeft)
        if timeLeft >= 86400 then
            self.duration:SetFormattedText("%dd", ceil(timeLeft / 86400))
        elseif timeLeft >= 3600 then
            self.duration:SetFormattedText("%dh", ceil(timeLeft / 3600))
        elseif timeLeft >= 60 then
            self.duration:SetFormattedText("%dm", ceil(timeLeft / 60))
        else
            self.duration:SetFormattedText("%ds", timeLeft)
        end
    end

    local function ButtonMasque(button)
        local icon = button.Icon
        local point, relativeTo, relativePoint, xOfs, yOfs = icon:GetPoint()


        local border = CreateFrame("Frame", nil, button)
        border:SetSize(icon:GetWidth(), icon:GetHeight())
        border:SetPoint("CENTER", button, "CENTER", 0, 5)

        border.debuff = CreateFrame("Frame", nil, border, "BackdropTemplate")

        button.SUIBorder = border
    end

    local function ButtonDefault(button)
        local Backdrop = {
            bgFile = nil,
            edgeFile = "Interface\\Addons\\SUI\\Media\\Textures\\Core\\outer_shadow",
            tile = false,
            tileSize = 32,
            edgeSize = 6,
            insets = { left = 6, right = 6, top = 6, bottom = 6 },
        }

        local icon = button.Icon

        local border = CreateFrame("Frame", nil, button)
        border:SetSize(icon:GetWidth() + 4, icon:GetHeight() + 4)
        border:SetPoint("CENTER", 0, 5)
        border:SetFrameLevel(8)

        border.texture = border:CreateTexture()
        border.texture:SetAllPoints()
        border.texture:SetTexture("Interface\\Addons\\SUI\\Media\\Textures\\Core\\gloss_border_w")
        --border.texture:SetVertexColor(0.20, 0.60, 1.00)
        border.texture:SetDrawLayer("BACKGROUND", -7)
        border.texture:SetTexCoord(0, 1, 0, 1)


        border.shadow = CreateFrame("Frame", nil, border, "BackdropTemplate")
        border.shadow:SetPoint("TOPLEFT", border, "TOPLEFT", -4, 4)
        border.shadow:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 4, -4)
        border.shadow:SetBackdrop(Backdrop)
        border.shadow:SetBackdropBorderColor(unpack(SUI:Color(0.25, 0.9)))

        button.SUIBorder = border
    end

    local function ButtonBackdrop(button)
        local Backdrop = {
            bgFile = "",
            edgeFile = "Interface\\Addons\\SUI\\Media\\Textures\\Core\\outer_shadow",
            tile = false,
            tileSize = 32,
            edgeSize = 5,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        }

        local icon = button.Icon
        local point, relativeTo, relativePoint, xOfs, yOfs = icon:GetPoint()

        local border = CreateFrame("Frame", nil, button)
        border:SetSize(icon:GetWidth(), icon:GetHeight())
        border:SetPoint("CENTER", button, "CENTER", 0, 5)

        border.debuff = CreateFrame("Frame", nil, border, "BackdropTemplate")
        border.debuff:SetBackdrop({
            bgFile = "",
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        --border.debuff:SetTexture("Interface\\Buttons\\WHITE8x8")
        border.debuff:SetAllPoints()

        local shadow = CreateFrame("Frame", nil, border, "BackdropTemplate")
        shadow:SetPoint("TOPLEFT", border, "TOPLEFT", -4, 4)
        shadow:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 4, -4)
        shadow:SetBackdrop(Backdrop)
        shadow:SetBackdropBorderColor(0, 0, 0)

        button.SUIBorder = border
    end

    local function ButtonBordered(button)

    end

    function updateDebuffs()
        local Children = { DebuffFrame.AuraContainer:GetChildren() }

        for index, child in pairs(Children) do
            local frame = select(index, DebuffFrame.AuraContainer:GetChildren())
            local icon = frame.Icon
            local duration = frame.duration
            local count = frame.count

            if child.Border then
                child.Border:Hide()
            end


            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            if (count) then
                -- Set Stack Font size and reposition it
                count:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
                count:ClearAllPoints()
                count:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
            end

            -- Set Duration Font size and reposition it
            duration:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
            duration:ClearAllPoints()
            duration:SetPoint("CENTER", frame, "BOTTOM", 0, 15)
            duration:SetDrawLayer("OVERLAY")

            if frame.SUIBorder == nil then
                ButtonDefault(frame)
            end

            -- Set the color of the Debuff Border
            local debuffType
            if (child.buttonInfo) then
                debuffType = child.buttonInfo.debuffType
            end
            if (frame.SUIBorder) then
                local color
                if (debuffType) then
                    color = DebuffColor[debuffType]
                else
                    color = DebuffColor["none"]
                end
                frame.SUIBorder.texture:SetVertexColor(color.r, color.g, color.b, 1)
            end
        end
    end

    if theme ~= 'Blizzard' then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD", self, "Update")
        frame:RegisterUnitEvent("UNIT_AURA", self, "Update")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:SetScript("OnEvent", function(self, event, ...)
            updateDebuffs()
        end)
    end

    hooksecurefunc(DebuffButtonMixin, "UpdateDuration", UpdateDuration)
end
