BIP = CreateFrame("Frame","BetterItemPreview")

function BIP:OnEvent(event, ...)
    arg1 = ...
    if event == "ADDON_LOADED" and arg1 == "BetterItemPreview" then
        BIP:Load()
    end
end

BIP:SetScript("OnEvent",BIP.OnEvent)
BIP:RegisterEvent("ADDON_LOADED")

function BIP:Load()
    self:Message("Better Item Preview (BIP) Loaded")
    if BetterItemPreview == nil or BetterItemPreview.Reverse == nil then
        BetterItemPreview = {
            Reverse = false,
        }
        self:Message("    BIP Savedvariables Not Found.\n    Defaults Loaded")
    end
    self:Message("    Use /bip to view or change settings")
    self:UnregisterEvent("ADDON_LOADED")
    BIP:Init()
end

function BIP:Message(msg,location)
    if msg == nil then
        return
    elseif location == "ERROR" then
        UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)    
    elseif location == "BOTH" then
        UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)    
        DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1)
    else
        DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1)
    end
end

function BIP:CurrentSettings()
    if BetterItemPreview.Reverse then
        self:Message("[BIP] CTRL + CLICK Previews Transmogged Appearance")
        self:Message("[BIP] CTRL + SHIFT + CLICK Previews Actual Appearance")
    else
        self:Message("[BIP] CTRL + CLICK Previews Actual Appearance")
        self:Message("[BIP] CTRL + SHIFT + CLICK Previews Transmogged Appearance")
    end
end

function BIP:SwapClicks(swap, ...)
    if swap == "swap" then
        BetterItemPreview.Reverse = not BetterItemPreview.Reverse
        BIP:CurrentSettings() 
    else
        BIP:CurrentSettings()
        self:Message("[BIP] To swap these, type: /bip swap")
    end
end

function BIP:Init()

    local originalDressUpLink = DressUpLink
    DressUpLink = function(link)
        --This just checks if it's a recipe, and if so, extracts the link for the item it creates and resends that to this function.
        ----If the resulting item isn't previewable, this will still do whatever it normally would've done in that case.
		if IsModifiedClick("DRESSUP") then
            link = BIP:RecipeRecurse(link)
        end

        return link and (DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link));
    end

    local originalHandleModifiedItemClick = HandleModifiedItemClick
    --HandleModifiedItemClick = function(link, itemLocation, ...)
    HandleModifiedItemClick = function(link, itemLocation)

		if IsModifiedClick("DRESSUP") then
            link = BIP:RecipeRecurse(link)
        end

        local showReal = true
        local inspect = nil

        if (IsShiftKeyDown() and not BetterItemPreview.Reverse) or (not IsShiftKeyDown() and BetterItemPreview.Reverse) then
            showReal = false
        end

		--I can't figure out what garbage MogIt is sending to this handler, but this appears to take care of that oddity
		if tonumber(itemLocation) ~= nil then
			itemLocation = nil
		end

        if (InspectFrame and InspectFrame.unit and itemLocation == nil) then
            local slotID = C_Transmog.GetSlotForInventoryType( C_Item.GetItemInventoryTypeByID( link ) + 1 )
            local inspectInfo = C_TransmogCollection.GetInspectItemTransmogInfoList()[slotID]
            if inspectInfo then
                inspect = (select(6,C_TransmogCollection.GetAppearanceSourceInfo(inspectInfo.appearanceID)))
            end
        end
            
        if inspect and showReal then
            link = inspect
            itemLocation = nil
        elseif showReal then
            itemLocation = nil
        end
            
        if IsModifiedClick("DRESSUP") and C_Item.IsDressableItemByID(link) then
            return DressUpItemLocation(itemLocation) or DressUpItemLink(link) or DressUpBattlePet(link) or DressUpMount(link)
        else
            originalHandleModifiedItemClick(link,itemLocation)
        end
    end

end

function BIP:RecipeRecurse(link)
    if link and (select(12,GetItemInfo(link))) == Enum.ItemRecipeSubclass then
        local linkID = link:match("item:([0-9]+):")
        local newLink = select(2,GetItemInfo((select(2,LibStub("LibRecipes-3.0"):GetRecipeInfo(linkID)))))
        return newLink
    else
        return link
    end
end

SLASH_BIP1 = "/bip"
SlashCmdList["BIP"] = function(msg,editBox) BIP:SwapClicks(msg); end
