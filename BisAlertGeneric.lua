-- TODO: Re-use frames for performance.
-- Approach: Create a frame with an icon in each slot, including inventory, then re-use that frame.
-- Approach: Consider how the manage adding a new bag to bag slot and expanding or reducing the slots.

function WrapInPink(text)
    return "|cffDA70D6"..text
end

function GetListOfItemSlots()
    return {
        "MainHand",
        "SecondaryHand",
        "Head",
        "Neck",
        "Shoulder",
        "Back",
        "Chest",
        "Wrist",
        "Hands",
        "Waist",
        "Legs",
        "Feet",
        "Finger1",
        "Finger0",
        "Trinket1",
        "Trinket0"
    }
end

function GetCurrentSpec(class, specId)
    local specToNameMap = {
        ['Death Knight'] = {
            [1] = 'Blood',
            [2] = 'Frost',
            [3] = 'Unholy'
        },
        ['Demon Hunter'] = {
            [1] = 'Havoc',
            [2] = 'Vengeance'
        },
        ['Druid'] = {
            [1] = 'Restoration',
            [2] = 'Guardian',
            [3] = 'Feral',
            [4] = 'Balance'
        },
        ['Evoker'] = {
            [1] = 'Devastation',
            [2] = 'Preservation'
        },
        ['Hunter'] = {
            [1] = 'Beast Mastery',
            [2] = 'Marksmanship',
            [3] = 'Survival Hunter'
        },
        ['Mage'] = {
            [1] = 'Arcane',
            [2] = 'Fire',
            [3] = 'Frost'
        },
        ['Monk'] = {
            [1] = 'Brewmaster',
            [2] = 'Mistweaver',
            [3] = 'Windwalker'
        },
        ['Paladin'] = {
            [1] = 'Holy',
            [2] = 'Protection',
            [3] = 'Retribution'
        },
        ['Priest'] = {
            [1] = 'Discipline',
            [2] = 'Holy',
            [3] = 'Shadow'
        },
        ['Rogue'] = {
            [1] = 'Assassination',
            [2] = 'Outlaw',
            [3] = 'Subtlety'
        },
        ['Shaman'] = {
            [1] = 'Elemental',
            [2] = 'Enhancement',
            [3] = 'Restoration'
        },
        ['Warlock'] = {
            [1] = 'Affliction',
            [2] = 'Demonology',
            [3] = 'Destruction'
        },
        ["Warrior"] = {
            [1] = 'Arms',
            [2] = 'Fury',
            [3] = 'Protection'
        }
    }
    return specToNameMap[class][specId]
end

function BIS_SplitStr(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function BIS_ClearIcons()
    if not BISFrames then
         do return end
    end
    for _, item in pairs(BISFrames) do
        item:Hide()
    end
    if not BISCharacterFrames then
        do return end
   end
   for _, item in pairs(BISCharacterFrames) do
       item:Hide()
   end
end

-- No event for BAG_OPEN, the BAG_OPEN even triggers on loot bags opening not player bag.
-- Once it's been checked, the frames exist then, you don't need to recheck.
function BIS_StartInventoryCheck()
    BIS_WaitForInventory = C_Timer.NewTicker(0.05, function ()
        local invOpen = ContainerFrameCombinedBags:IsVisible()
        if invOpen then
            Bags({ assign = true })
            BIS_ClearIcons()
            BIS_EnumerateInventory()
            BIS_WaitForInventory:Cancel()
        end
    end)
end

function BIS_SetBISItem(class, spec, slot, itemName)
    -- If one already exists, use that one.
    if _G["BisItems"][class..spec] then
        BIS_GetBISItems(class, spec)
    end

    if not _G["BisItems"] then
        _G["BisItems"] = {}
    end

    if not _G["BisItems"][class..spec] then
        _G["BisItems"][class..spec] = {}
    end

    _G["BisItems"][class..spec][slot] = strtrim(itemName, ' ');
end

function BIS_GetBISItems(class, spec)

    if not spec then do return end end

    local BisItemsForClass = _G["BisItems"][class..spec]

    if BisItemsForClass then
        for _, value in pairs(GetListOfItemSlots()) do
            if not BisItemsForClass[value] then
                BisItemsForClass[value] = ''
            end
        end
        return BisItemsForClass
    end

    -- If it doesn't exist, create a BIS item table.
    _G["BisItems"][class..spec] = {}
    local bisItems = _G["BisItems"][class..spec]

    local noItemSelected = 'No item selected'
    -- Apply blank bis
    bisItems["MainHand"] = noItemSelected
    bisItems["SecondaryHand"] = noItemSelected
    bisItems["Head"] = noItemSelected
    bisItems["Neck"] = noItemSelected
    bisItems["Shoulder"] = noItemSelected
    bisItems["Back"] = noItemSelected
    bisItems["Chest"] = noItemSelected
    bisItems["Wrist"] = noItemSelected
    bisItems["Hands"] = noItemSelected
    bisItems["Waist"] = noItemSelected
    bisItems["Legs"] = noItemSelected
    bisItems["Feet"] = noItemSelected
    bisItems["Finger0"] = noItemSelected
    bisItems["Finger1"] = noItemSelected
    bisItems["Trinket0"] = noItemSelected
    bisItems["Trinket1"] = noItemSelected

    return bisItems
end

function BIS_IsItemBestInSlotItem (itemId)
    local characterItems = BIS_GetBISItems(UnitClass('player'), GetCurrentSpec(UnitClass('player'), GetSpecialization())) or nil
    if characterItems == nil then
        print(WrapInPink("We couldn't load your best in slot items, try reloading the addon or reseting your settings."))
        do return end
    end
    for _, value in pairs(characterItems) do
        if itemId == value then
            do return true end
        end
    end
    return false
end

function BIS_EnumerateInventory()
    if BISOptions_ShowIcons == 'enabled' then

        local f = _G["ContainerFrameCombinedBags"]
        local children = {f:GetChildren()}
        for _, frame in ipairs(children) do
            -- If the frame is a combined bags item
            local frameName = frame:GetDebugName()
            if (string.match(frameName, "ContainerFrameCombinedBags%.[a-f0-9]+")) then
                -- See if there's an item in the slot
                if (frame.GetItemInfo ~= nil) then
                    -- Try risky move.
                    local success, result = pcall(function ()
                        local itemLink = frame:GetItemInfo()
                        if (itemLink ~= nil) then
                            return itemLink
                        end
                    end)

                    if success then
                        -- Found an item in a slot
                        local itemId = GetItemInfoFromHyperlink(result) or 0
                        local itemName = GetItemInfo(itemId)
                        local isBIS = BIS_IsItemBestInSlotItem(itemName)
                        if isBIS == true then
                            local marker = BIS_ApplyNewIcon(frame)
                            table.insert(BISFrames, marker)
                        end
                    end
                end
            end
        end

        -- Iterate through item slots in character panel.
        for _, slot in pairs(GetListOfItemSlots()) do
            local invSlotId = GetInventorySlotInfo(string.upper(slot).."SLOT")
            local itemLink = GetInventoryItemLink('player', invSlotId)
            if itemLink ~= nil then
                local itemId = GetItemInfoFromHyperlink(itemLink) or 0
                local itemName = GetItemInfo(itemId)
                local isBIS = BIS_IsItemBestInSlotItem(itemName)
                if isBIS == true then
                    local marker = BIS_ApplyNewIcon(_G["Character"..slot.."Slot"])
                    table.insert(BISCharacterFrames, marker)
                end
            end
        end
    end
end

function BIS_ApplyNewIcon(parent)

    local textureId;
    local width;
    local height;
    local alpha;

    if BISOptions_IconType == 'purple' then
        textureId = 'Nzoth-charactersheet-item-glow';
        width = 66
        height = 66
        alpha = 0.7
    elseif BISOptions_IconType == 'gold' then
        textureId = 'BonusChest-ItemBorder-Uncommon'
        width = 57
        height = 57
        alpha = 1
    elseif BISOptions_IconType == 'silver' then
        textureId = 'dressingroom-itemborder-white'
        width = 41
        height = 41
        alpha = 1
    elseif BISOptions_IconType == 'fancygold' then
        textureId = 'professions-recrafting-frame-item'
        width = 41
        height = 41
        alpha = 1
    end

    local f = CreateFrame("Frame", nil, parent)
    f:SetFrameStrata("TOOLTIP")
    f:SetWidth(width)
    f:SetHeight(height)
    f:SetAlpha(alpha)

    local t = f:CreateTexture(nil, "OVERLAY")
    t:SetAtlas(textureId)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("CENTER", 0, 0)
    f:Show()

    return f;
end

function Bags(opts)
    if not opts then opts = {} end
    local bags = {}
    if opts["assign"] == true then
        BISLastBag = {}
    end
    for i = 0, 7 do
        for j = 0, 40 do
            local frame = _G["ContainerFrame"..i.."Item"..j]
            if frame ~= nil then
                local itemLink = ContainerFrameItemButton_GetDebugReportInfo(frame).itemLink
                if itemLink ~= nil then
                    local itemId = GetItemInfoFromHyperlink(itemLink) or 0
                    table.insert(bags, itemId)
                    if opts["assign"] == true then
                        InitialBagAssign = true;
                        table.insert(BISLastBag, itemId)
                    end
                end
            end
        end
    end

    return bags
end

function InventoryItems(opts)
    if not opts then opts = {} end
    if opts["assign"] == true then
        BISLastInventory = {}
    end
    for _, slot in pairs(GetListOfItemSlots()) do
        local invSlotId = GetInventorySlotInfo(string.upper(slot).."SLOT")
        local itemLink = GetInventoryItemLink('player', invSlotId)
        if itemLink ~= nil then
            local itemId = GetItemInfoFromHyperlink(itemLink) or 0
            if opts['assign'] == true then
                BISLastInventory[slot] = itemId
            end
        end
    end
    InitialInventoryAssign = true
end

function PopupItem(itemId)
    local itemName, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
    if itemName == nil then
        print(WrapInPink('You got a a best in slot item, but we couldn\'t figure out what it was, check you\'re inventory'))
        do return end
    end

    local screenHeight = GetScreenHeight()
    local padding = 50;

    -- Container
    local bannerFrame = CreateFrame('Frame', 'BisBannerFrame', UIParent)
    bannerFrame:SetFrameStrata('TOOLTIP')
    bannerFrame:SetWidth(302)
    bannerFrame:SetHeight(119)

    -- Texture
    bannerFrame.texture = bannerFrame:CreateTexture(nil, 'OVERLAY')
    bannerFrame.texture:SetAtlas('LegendaryToast-background')
    bannerFrame.texture:SetAllPoints(bannerFrame)
    bannerFrame:SetPoint("CENTER", -20, (screenHeight / 2) - (119 + padding))

    -- Text
    bannerFrame.text = bannerFrame:CreateFontString(nil, 'OVERLAY')
    bannerFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12, 'OUTLINE')
    bannerFrame.text:SetPoint('CENTER', 42, 10)
    bannerFrame.text:SetJustifyV("MIDDLE")
    bannerFrame.text:SetJustifyH("CENTER")
    bannerFrame.text:SetWidth(160)
    bannerFrame.text:SetText('You just found a new best in slot item!')

    -- Item Text
    bannerFrame.itemText = bannerFrame:CreateFontString(nil, 'OVERLAY')
    bannerFrame.itemText:SetFont("Fonts\\FRIZQT__.TTF", 12, 'OUTLINE')
    bannerFrame.itemText:SetTextColor(1, 0.5, 0)
    bannerFrame.itemText:SetPoint('CENTER', 42, -10)
    bannerFrame.itemText:SetJustifyV("MIDDLE")
    bannerFrame.itemText:SetJustifyH("CENTER")
    bannerFrame.itemText:SetWidth(160)
    bannerFrame.itemText:SetText('['..itemName..']')

    -- Icon
    bannerFrame.icon = bannerFrame:CreateTexture(nil, 'BORDER')
    bannerFrame.icon:SetTexture(texture)
    bannerFrame.icon:SetHeight(50)
    bannerFrame.icon:SetWidth(50)
    bannerFrame.icon:SetPoint("CENTER", -76, 2)

    -- Events
    bannerFrame:SetScript('OnMouseDown', function (self, button)
        if button == 'LeftButton' then
            bannerFrame:Hide()
        end
    end)

    -- Show and animation
    bannerFrame:SetAlpha(0);
    bannerFrame:Show();

    if BISOptions_PlaySounds == 'enabled' then
        PlaySound(44322, 'master')
    end
    C_Timer.NewTicker(0.01, function ()
        local bannerAlpha = bannerFrame:GetAlpha();
        bannerFrame:SetAlpha(math.min(bannerAlpha + 0.15, 1));
    end, 7)

    C_Timer.After(5, function ()
        C_Timer.NewTicker(0.01, function ()
            local bannerAlpha = bannerFrame:GetAlpha();
            bannerFrame:SetAlpha(math.max(bannerAlpha - 0.15, 0));
        end, 7)
    end)
end