local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local dataManager = require(ServerScriptService.Modules.DataManager)

local function TryAddWeapon(player: Player, weaponName: string): boolean
    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data
    local weapons: {[string]: boolean} = data["Weapons"]

    if weapons then
        if not weapons[weaponName] then
            weapons[weaponName] = true
        else
            return false
        end
    else
        data["Weapons"] = {[weaponName] = true}
    end

    return true
end

local function TryPurchaseWeapon(player: Player, weaponName: string): boolean
    local weapon: Model = ReplicatedStorage.Weapons:FindFirstChild(weaponName)
    if not weapon then
        print("Error: Weapon with given name does not exist.")
        return false
    end

    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data
    local cash: number = data["Cash"]
    local cost: number = weapon:GetAttribute("cost") or 0

    if cash >= cost then
        if TryAddWeapon(player, weaponName) then
            cash -= cost
            print("Success: " .. cash .. " Cash remaining.")
            return true
        else
            print("Error: Weapon already owned.")
            return false
        end
    else
        print("Error: Insufficient funds.")
        return false
    end
end

ReplicatedStorage.RemoteFunctions.ShopGui.TryPurchaseWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return TryPurchaseWeapon(player, weaponName)
end)