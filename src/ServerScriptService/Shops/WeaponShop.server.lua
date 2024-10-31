local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local dataManager: table = require(ServerScriptService.Modules.DataManager)
local weapons: Folder = ReplicatedStorage.Weapons
local shopGuiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui

local function TryAddWeapon(player: Player, weaponName: string): boolean
    local weapon = weapons:FindFirstChild(weaponName)
    if weapon == nil then return false end

    local weaponType = weapon:GetAttribute("weaponType")
    if weaponType == nil then return false end

    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data
    local ownedWeapons: {[string]: {[string]: boolean}} = data["Weapons"]
    local weaponVariants: {[string]: boolean} = ownedWeapons and ownedWeapons[weaponType] or nil
    local isOwned: boolean = weaponVariants and weaponVariants[weaponName] or nil

    if isOwned then
        return false
    elseif weaponVariants then
        weaponVariants[weaponName] = true
    elseif ownedWeapons then
        ownedWeapons[weaponType] = {[weaponName] = true}
    else
        data["Weapons"] = {[weaponType] = {[weaponName] = true}}
    end

    return true
end

local function EquipWeapon(player: Player, weaponName: string)
    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data
    local equippedWeapons: {[string]: {[string]: boolean}} = data["Equipped"]
    local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)

    if weaponTemplate then
        local weapon: Tool = weaponTemplate:Clone()
        local weaponType: string = weapon:GetAttribute("weaponType")

        weapon.Parent = player.Backpack

        if equippedWeapons then
            equippedWeapons[weaponType] = weaponName
        else
            equippedWeapons = {[weaponType] = weaponName}
        end
    end
end

local function TryPurchaseWeapon(player: Player, weaponName: string): boolean
    local weapon: Tool = weapons:FindFirstChild(weaponName)
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

local function GetEquippedWeapons(player: Player): {[string]: string}
    while not dataManager.Profiles[player] do
        task.wait(1)
    end

    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data

    if not data["Equipped"] then
        data["Equipped"] = {}
    end

    return data["Equipped"]
end

local function EquipEquippedWeapons(player: Player)
    local equippedWeapons: {[string]: {[string]: string}} = GetEquippedWeapons(player)
    local firstWeaponName: string = equippedWeapons[next(equippedWeapons)]

    for _: string, weaponName: string in pairs(equippedWeapons) do
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
        EquipEquippedWeapons(player)
    end)
end)