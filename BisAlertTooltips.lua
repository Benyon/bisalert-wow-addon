local function GameTooltip_OnTooltipSetItem(tooltip)
    if tooltip.GetItem then
        local _, itemLink = tooltip:GetItem()
        if (itemLink) then
            local itemId = GetItemInfoFromHyperlink(itemLink)
            local engraving = GetEngravingFromId(itemId)
            if engraving ~= '' then
                tooltip:AddLine(" ")
                tooltip:AddLine("\"".. engraving .."\"", 0.83, 0.68, 0.21, true)
            end
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_OnTooltipSetItem)