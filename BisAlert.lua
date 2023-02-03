BisAlert = LibStub('AceAddon-3.0'):NewAddon("BisAlert", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

BISFrames = {}
BISCharacterFrames = {}
BISLastBag = {}
BISLastInventory = {}
InitialBagAssign = false
InitialInventoryAssign = false

-- UI

local options = {
	name = "Best In Slot Alert (BisAlert)",
	handler = BisAlert,
	type = "group",
	args = {
        displayHeader = {
            order = 0,
            type = 'header',
            name = 'Display Options'
        },
		toggleIcons = {
            order = 1,
			type = "toggle",
            width = "full",
			name = "Show Icons",
			desc = "Toggle to show icons on BIS items.",
			get = "IsIconsEnabled",
			set = "ToggleIconsEnabled"
		},
        iconType = {
            order = 2,
			type = "select",
			name = "Icon Type",
            values = { ['purple'] = 'Purple', ['gold'] = 'Gold', ['silver'] = 'Silver', ['fancygold'] = 'Fancy Gold' },
            get = "GetIconType",
            set = "SetIconType"
		},
        header = {
            type = 'header',
            name = 'Item Options'
        },
        resetSettings = {
            type = "execute",
            name = "Reset settings",
            func = function ()
                BISOptions_IconType = 'purple'
                BISOptions_ShowIcons = 'enabled'
                print(WrapInPink("Settings have been reset."))
            end
        },
        reset = {
            type = "execute",
            name = "Reset all items",
            func = function ()
                BisItems = {}
                print(WrapInPink("BIS items have been reset for all classes"))
            end
        },
        editor = {
            type = "execute",
            name = "Open Editor",
            func = 'OpenEditor'
        }
	},
}

local function DrawGroup(container, spec)
    local playerClass = UnitClass('player');
    container:SetLayout("List")
    local specLabel = AceGUI:Create('Label')
    specLabel:SetText('The following items are your best in slot for specalisation: '.. GetCurrentSpec(playerClass, spec))
    container:AddChild(specLabel)
    for _, slot in pairs(GetListOfItemSlots()) do
        local currentChosenBIS = BIS_GetBISItems(playerClass, GetCurrentSpec(playerClass, spec))
        local textBox = AceGUI:Create("EditBox");
        textBox:SetLabel(slot .. " Slot")
        textBox:SetText(currentChosenBIS[slot]);
        textBox:SetCallback('OnEnterPressed', function (_, _, text)
            BIS_SetBISItem(playerClass, GetCurrentSpec(playerClass, spec), slot, text)
            BIS_ClearIcons()
            BIS_EnumerateInventory()
        end)
        container:AddChild(textBox);
    end
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "spec1" then
        DrawGroup(container, 1)
    elseif group == "spec2" then
        DrawGroup(container, 2)
    elseif group == "spec3" then
        DrawGroup(container, 3)
    elseif group == "spec4" then
        DrawGroup(container, 4)
    end
end

function BisAlert:OpenEditor()
    local listOfSpecs = {}
    for i in pairs({1, 2, 3, 4}) do
        local specName = GetCurrentSpec(UnitClass('player'), i)
        if specName then
            table.insert(listOfSpecs, {
                text = specName,
                value = "spec"..i
            })
        end
    end

    local frame = AceGUI:Create("Frame")
    frame:SetHeight(850)
    frame:SetWidth(500)
    frame:SetTitle("BIS Alert Editor")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Fill")

    local tab =  AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    tab:SetTabs(listOfSpecs)
    tab:SetCallback("OnGroupSelected", SelectGroup)

    local playerSpecId = GetSpecialization()
    tab:SelectTab("spec"..playerSpecId)

    frame:AddChild(tab)
end

-- Main

function BisAlert:OnInitialize()

    if not BisItems then
        BisItems = {}
    end

    -- Options and settings.
	AceConfig:RegisterOptionsTable("BisAlert", options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("BisAlert", "BisAlert")

    -- Commands
	self:RegisterChatCommand("bisalert", "SlashCommand")

    -- Settings
    if not BISOptions_ShowIcons then
        BISOptions_ShowIcons = 'enabled'
    end

    if not BISOptions_IconType then
        BISOptions_IconType = 'purple'
    end

    InventoryItems({ assign = true })
    BIS_StartInventoryCheck()
    print(WrapInPink('BisAlert has loaded.'))
end

-- Events 

function BisAlert:OnEnable()
	self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function BisAlert:UNIT_INVENTORY_CHANGED(_, unit)
    if unit == 'player' then
        BIS_ClearIcons()
        BIS_EnumerateInventory()
    end
end

function BisAlert:BAG_UPDATE()
    BIS_ClearIcons();
    BIS_EnumerateInventory();

    -- Check if new bag scan has new item in it.
    local afterUpdatedBags = Bags();
    if not InitialBagAssign or not InitialInventoryAssign then
        Bags({ assign = true });
        InventoryItems({ assign = true })
        do return end
    end

    local newItemFound = nil;
    for _, newItem in pairs(afterUpdatedBags) do -- for every item in the new bag
        local matchedItem = false;
        for _, oldItem in pairs(BISLastBag) do -- check every item in the old bag scan
            if (newItem == oldItem) then -- if the new item has a match in the old inventory
                matchedItem = true;
                break;
            end
        end
        if not matchedItem then -- If there isn't an item matching in the old inv, that new item is probably the new one
            newItemFound = newItem;
            break; -- Break out of the full inventory search
        end
    end

    -- Now we check if it was actually an item we equipped anyway.
    if newItemFound ~= nil then
        local swapMatch = false;
        for _, lastInventoryItem in pairs(BISLastInventory) do
            if newItemFound == lastInventoryItem then
                swapMatch = true;
                break;
            end
        end
        if not swapMatch then
            local itemName = GetItemInfo(newItemFound)
            local isBIS = BIS_IsItemBestInSlotItem(itemName)
            if isBIS == true then
                PopupItem(newItemFound)
            end
        end
    end
    Bags({ assign = true })
    InventoryItems({ assign = true })
end

function BisAlert:PLAYER_SPECIALIZATION_CHANGED()
    BIS_ClearIcons()
    BIS_EnumerateInventory()
end

-- Methods

function BisAlert:IsIconsEnabled()
    if BISOptions_ShowIcons == 'enabled' then
        return true
    else
        return false
    end
end

function BisAlert:ToggleIconsEnabled(_, value)
    local v = (value and 'enabled' or 'disabled')
	BISOptions_ShowIcons = v
    if value == false then
        BIS_ClearIcons()
    else
        BIS_EnumerateInventory()
    end
end

function BisAlert:GetIconType()
	return BISOptions_IconType
end

function BisAlert:SetIconType(_, value)
	BISOptions_IconType = value
    BIS_ClearIcons()
    BIS_EnumerateInventory()
end

-- Commands

function BisAlert:SlashCommand()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

-- Hooks

CharacterFrame:HookScript('OnShow', function ()
    BIS_ClearIcons()
    BIS_EnumerateInventory()
end)