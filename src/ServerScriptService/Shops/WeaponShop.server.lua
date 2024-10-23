-- local ServerScriptService = game:GetService("ServerScriptService")
-- local dataManager = require(ServerScriptService.Modules.DataManager)

-- local function TryAddWeapon(player: Player, weaponName: string): boolean
--     local profile: table = dataManager.Profiles[player]
--     local data: {[string]: any} = profile.Data
--     local weapons: {[string]: boolean} = data["Weapons"]

--     if weapons then
--         if not weapons[weaponName] then
--             weapons[weaponName] = true
--         else
--             return false
--         end
--     else
--         data["Weapons"] = {[weaponName] = true}
--     end

--     return true
-- end

-- local function TryPurchaseWeapon(player: Player, weaponName: string, price: number)
--     local profile: table = dataManager.Profiles[player]
--     local data: {[string]: any} = profile.Data
--     local cash: number = data["Cash"]

--     if cash >= price then
--         if TryAddWeapon(player, weaponName) then
--             cash -= price
--             print("Success: " .. cash .. " Cash remaining.")
--         else
--             print("Error: Weapon already owned.")
--         end
--     else
--         print("Error: Insufficient funds.")
--     end
-- end

-- TryPurchaseWeapon(game:GetService("Players"):GetPlayerByUserId(31571502), "TestWeapon", 0)