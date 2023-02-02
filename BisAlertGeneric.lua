function WrapInGold(text)
    return "|cffffcc00"..text
end

function SplitStr(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function AddEngravingToItemId(id, text)
    for _, value in pairs(EngravingsTable) do
        local extractedId = SplitStr(value, "/---/")[1]
        if extractedId == tostring(id) then
            return false
        end
    end
    table.insert(EngravingsTable, id.."/---/"..text)
    return true
end

function RemoveEngraving(id)
    local index = -1
    for key, value in pairs(EngravingsTable) do
        local extractedId = SplitStr(value, "/---/")[1]
        if extractedId == tostring(id) then
            index = key
        end
    end
    if (index ~= -1) then
        table.remove(EngravingsTable, index)
        return true
    end
    return false
end

function GetEngravingFromId(id)
    for _, value in pairs(EngravingsTable) do
        local extractedId = SplitStr(value, "/---/")[1]
        local message = SplitStr(value, "/---/")[2]
        if extractedId == tostring(id) then
            return message
        end
    end
    return ''
end

function ClearIcons()
    if EngraveIconsOption == true then
        table.foreach(EngraveFrames, function (_, item)
            item:Hide()
        end)
    end
end

function EnumerateInventory()
    if EngraveIconsOption == true then
        for i = 0, 7 do
            for j = 0, 40 do
                local frame = _G["ContainerFrame"..i.."Item"..j]
                if frame ~= nil then
                    local itemLink = ContainerFrameItemButton_GetDebugReportInfo(frame).itemLink
                    if itemLink ~= nil then
                        local itemId = GetItemInfoFromHyperlink(itemLink)
                        local engraving = GetEngravingFromId(itemId)
                        if engraving ~= '' then
                            local marker = ApplyNewIcon(frame)
                            table.insert(EngraveFrames, marker)
                        end
                    end
                end
            end
        end
    end
end

function ApplyNewIcon(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetFrameStrata("TOOLTIP")
    f:SetWidth(48)
    f:SetHeight(49)

    local t = f:CreateTexture(nil, "OVERLAY")
    t:SetAtlas("mountequipment-slot-corners")
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("CENTER", 0, 0)
    f:Show()

    return f;
end

-- No event for BAG_OPEN, the BAG_OPEN even triggers on loot bags opening not player bag.
-- Once it's been checked, the frames exist then, you don't need to recheck.
function StartInventoryCheck()
    WaitForInventory = C_Timer.NewTicker(0.05, function ()
        local invOpen = ContainerFrameCombinedBags:IsVisible()
        if invOpen then
            ClearIcons()
            EnumerateInventory()
            WaitForInventory:Cancel()
        end
    end)
end
