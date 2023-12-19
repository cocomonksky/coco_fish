local VORPInv = {}
local VorpCore = {}

TriggerEvent("getCore", function(core) -- get core 
    VorpCore = core
end)
VORPInv = exports.vorp_inventory:vorp_inventoryApi() -- get inventory 

for ItemToUse, value in pairs(Config.Rewards) do -- for loop to look for values in table Config

    VORPInv.RegisterUsableItem(ItemToUse, function(data) -- inventory API to use and register usable items
        local _source = data.source -- the player that is using the item
        local Character = VorpCore.getUser(_source).getUsedCharacter -- get user 

        for key, v in pairs(value.ItemsName) do -- a for loop get items because they are in a table
            -- localize as much you can it helps to read code faster
            local amount = v.amount
            local ItemName = v.name
            -- always check if player can carry items before giving
            local canCarry = VORPInv.canCarryItems(_source, amount) --can carry inv space
            local canCarry2 = VORPInv.canCarryItem(_source, ItemName, amount) --cancarry item limit
            local itemCheck = VORPInv.getDBItem(_source, ItemName) --check items exist in DB for dev error
            -- check individually to easily let the player know why he cant have the item
            if itemCheck then
                if canCarry then
                    if canCarry2 then
                        VORPInv.subItem(_source, ItemToUse, 1) -- remove the item you used
                        VORPInv.addItem(_source, ItemName, amount) -- add all items from list and amount

                        VorpCore.NotifyRightTip(_source, "you got " .. ItemName .. " amount " .. amount, 3000) -- notify the player what he got
                    else
                        print("item limit cant be carried") -- add a notification
                    end
                else
                    print("inv space is full") -- add a notification
                end
            else
                print("items does not exist or is wrong named cause you are a fool") -- leave it as print so dev know
            end
        end

        for key, v in pairs(value.WeaponsName) do -- for loop to get weapons table
            local weapName = v.name
            -- chek if payer can carry amount of weapons before giving them
            VORPInv.canCarryWeapons(_source, 1, function(cb) --can carry weapons?
                local canCarry = cb -- returns true or false
                if canCarry then
                    VORPInv.createWeapon(_source, weapName) -- create weapon
                else
                    VorpCore.NotifyRightTip(_source, "you cant carry more weapons", 4000)
                end

            end)
        end

        Character.addCurrency(0, tonumber(value.currency)) -- add money to player

    end)
end


