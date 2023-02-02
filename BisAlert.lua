local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("BAG_UPDATE")

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Engrave" then
        if EngravingsTable == nil then
            EngravingsTable = {}
        end
        if EngraveIconsOption == nil then
            EngraveIconsOption = true
        end
        EngraveFrames = {}
    StartInventoryCheck()
    local formatted = (EngraveIconsOption and "on" or "off")
    print(WrapInGold('Engrave has loaded, your icons are set to: '..formatted))
    end

    if event == "BAG_UPDATE" then
        if EngraveIconsOption == true then
            ClearIcons()
            EnumerateInventory()
        end
    end
end

frame:SetScript("OnEvent", frame.OnEvent);