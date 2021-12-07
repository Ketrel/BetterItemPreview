BIP = LibStub("AceAddon-3.0"):NewAddon("Better Item Preview")

function BIP:OnInitialize()
    local defaults = {
        profile = {
            reverse = false,
        },
    }

    self.db = LibStub("AceDB-3.0"):New("BetterItemPreview", defaults, true)

    local options = {
        type = "group",
        args = {
            reverse = {
                name = "Reverse Functionality",
                desc = "Reverses the Ctrl+Click and Ctrl+Shift+Click Behavior",
                type = "toggle",
                descStyle = "inline",
                width = "full",
                get = function(info) return self.db.profile.reverse or false; end,
                set = function(info,val) self.db.profile.reverse = val; end,
            },
        },
    }

    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Better Item Preview", {type="group",args={}})
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Better Item Preview Options", options)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Better Item Preview Profiles", profileOptions)

    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Better Item Preview", "Better Item Preview", nil)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Better Item Preview Options", "Options", "Better Item Preview")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Better Item Preview Profiles", "Profiles", "Better Item Preview")


    local originalHandleModifiedItemClick = HandleModifiedItemClick
    HandleModifiedItemClick = function(link, itemLocation, ...)
        local showReal = false
        local inspect = ...

        if (IsShiftKeyDown() and not self.db.profile.reverse) or (not IsShiftKeyDown() and self.db.profile.reverse) then
            showReal = true
        end

        if IsModifiedClick("DRESSUP") and C_Item.IsDressableItemByID(link) then
            if showReal and itemLocation then
                return BIP.DressUpItemLocationReal(itemLocation) or DressUpItemLink(link) or DressUpBattlePet(link) or DressUpMount(link)
            else
                return DressUpItemLocation(itemLocation) or DressUpItemLink(link) or DressUpBattlePet(link) or DressUpMount(link)
            end
        else
            originalHandleModifiedItemClick(link,itemLocation)
        end
    end

end

function BIP:DressUpItemLocationReal(itemLocation)
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
