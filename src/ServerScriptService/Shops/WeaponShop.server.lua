local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local dataManager = require(ServerScriptService.Modules.DataManager)
local shopGuiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui

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

local function EquipWeapon(player: Player, weaponName: string)
    local weaponTemplate: Tool = ReplicatedStorage.Weapons:FindFirstChild(weaponName)

    if weaponTemplate then
        local weapon: Tool = weaponTemplate:Clone()
        weapon.Parent = player.Backpack
    end
end

local function TryPurchaseWeapon(player: Player, weaponName: string): boolean
    local weapon: Tool = ReplicatedStorage.Weapons:FindFirstChild(weaponName)
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
            EquipWeapon(player, weaponName)
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

local function GetOwnedWeapons(player: Player): {[string]: boolean}
    while not dataManager.Profiles[player] do
        task.wait(1)
    end

    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data

    if not data["Weapons"] then
        data["Weapons"] = {}
    end

    return data["Weapons"]
end

local function EquipOwnedWeapons(player: Player)
    local ownedWeapons: {[string]: boolean} = GetOwnedWeapons(player)
    local firstWeaponName: string = next(ownedWeapons)

    for weaponName: string, _: boolean in pairs(ownedWeapons) do
        EquipWeapon(player, weaponName)
    end

    if firstWeaponName then
        player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild(firstWeaponName))
    end
end

shopGuiRemoteFunctions.TryPurchaseWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return TryPurchaseWeapon(player, weaponName)
end)

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function()
        EquipOwnedWeapons(player)
    end)
end)