function DressUpItemLocationReal(itemLocation)
    if( itemLocation and itemLocation:IsValid() ) then
        local itemTransmogInfo = C_Item.GetCurrentItemTransmogInfo(itemLocation);
		itemTransmogInfo:Clear()
        -- non-equippable items won't have an appearanceID
        if itemTransmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
            return DressUpItemTransmogInfo(itemTransmogInfo);
        end
    end
    return false;
end

local originalHandleModifiedItemClick = HandleModifiedItemClick
HandleModifiedItemClick = function(link, itemLocation)
    if IsModifiedClick("DRESSUP") and C_Item.IsDressableItemByID(link) then
        if IsShiftKeyDown() and itemLocation then
			return DressUpItemLocationReal(itemLocation) or DressUpItemLink(link) or DressUpBattlePet(link) or DressUpMount(link)
		else
			return DressUpItemLocation(itemLocation) or DressUpItemLink(link) or DressUpBattlePet(link) or DressUpMount(link)
        end
    else
		originalHandleModifiedItemClick(link,itemLocation)
	end
end
