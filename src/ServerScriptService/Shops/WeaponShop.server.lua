local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataManager: table = require(ServerScriptService.PlayerDataManager)
local InventoryManager: table = require(ServerScriptService.Inventory.InventoryManager)
local InventoryDefinitions: {string} = require(ReplicatedStorage.Definitions.Inventory.InventoryDefinitions)
local weapons: Folder = ReplicatedStorage.Weapons
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui

local function TryAddWeapon(player: Player, weaponName: string): string
    local weapon = weapons:FindFirstChild(weaponName)
    if weapon == nil then return false end

    local weaponType = weapon:GetAttribute("weaponType")
    if weaponType == nil then return false end

    local ownedWeapons: {[string]: {string}} = InventoryManager.GetOwnedWeapons(player)
    local weaponVariants: {string} = ownedWeapons and ownedWeapons[weaponType] or nil
    local isOwned: boolean = weaponVariants and weaponVariants[weaponName] or nil

    if isOwned then
        return false
    else
        if weaponType == InventoryDefinitions.PrimaryWeaponTypeName then
            PlayerDataManager.addUnlockedRifleSkin(player, weaponName)
        else
            PlayerDataManager.addUnlockedPistolSkin(player, weaponName)
        end
    end

    return true, weaponType
end

local function TryPurchaseWeapon(player: Player, weaponName: string): boolean
    local weapon: Tool = weapons:FindFirstChild(weaponName)
    if not weapon then
        print("Error: Weapon with given name does not exist.")
        return false
    end

    local money: number = PlayerDataManager.getMoney(player)
    local cost: number = weapon:GetAttribute("cost") or 0

    if money >= cost then
        local success: boolean, weaponType: string = TryAddWeapon(player, weaponName)

        if success then
            money -= cost
            PlayerDataManager.updateMoneyAdd(player, cost * -1)
            InventoryManager.TryEquipWeapon(player, weaponName, weaponType)
            print("Success: " .. money .. " money remaining.")
            ReplicatedStorage.Events.Inventory.WeaponPurchasedEvent:FireClient(player, weaponName, money)
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

guiRemoteFunctions.TryPurchaseWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return TryPurchaseWeapon(player, weaponName)
end)