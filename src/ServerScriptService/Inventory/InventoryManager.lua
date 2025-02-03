local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataManager: table = require(ServerScriptService.PlayerDataManager)
local InventoryDefinitions: {string} = require(ReplicatedStorage.Definitions.Inventory.InventoryDefinitions)
local weapons: Folder = ReplicatedStorage.Weapons
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local inventory: Folder
local InventoryManager: table = {}

local function SpawnInventory(player: Player): Folder
    local newInventory = Instance.new("Folder")
    newInventory.Name = "Inventory"
    newInventory.Parent = player

    return newInventory
end

local function EquipOwnedWeapons(player: Player)
    local ownedWeapons: table =
    {
        [InventoryDefinitions.PrimaryWeaponTypeName] = PlayerDataManager.getRifleSkins(player),
        [InventoryDefinitions.SecondaryWeaponTypeName] = PlayerDataManager.getPistolSkins(player)
    }
    local equippedWeapons: table =
    {
        [InventoryDefinitions.PrimaryWeaponTypeName] = PlayerDataManager.getEquippedRifleSkin(player),
        [InventoryDefinitions.SecondaryWeaponTypeName] = PlayerDataManager.getEquippedPistolSkin(player)
    }

    inventory = inventory or SpawnInventory(player)

    for _: string, weaponList: {string} in pairs(ownedWeapons) do
        for _: number, weaponName: string in ipairs(weaponList) do
            local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
            local weapon: Tool = weaponTemplate and weaponTemplate:Clone()

            if weapon then
                weapon:SetAttribute("Equipped", nil)
                weapon.Parent = inventory
            end
        end
    end

    for _: string, weaponName: string in pairs(equippedWeapons) do
        local weapon = inventory:FindFirstChild(weaponName)

        if weapon then
            weapon.Parent = player.Backpack
        end
    end

    if player.Backpack:FindFirstChildOfClass("Tool") then
        player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChildOfClass("Tool"))
    end
end

function InventoryManager.GetOwnedWeapons(player: Player): table
    local ownedWeapons: {[string]: {string}} =
    {
        [InventoryDefinitions.PrimaryWeaponTypeName] = PlayerDataManager.getRifleSkins(player),
        [InventoryDefinitions.SecondaryWeaponTypeName] = PlayerDataManager.getPistolSkins(player)
    }

    return ownedWeapons
end

function InventoryManager.TryEquipWeapon(player: Player, weaponName: string): boolean
    local ownedWeapons: table
    local equippedWeaponName: string
    local backpack: Backpack = player.Backpack
    local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
    local weaponType: string = weaponTemplate:GetAttribute("weaponType")

    if not weaponTemplate then
        print(string.format("Weapon skin \"%s\" does not exist.", weaponName))
        return false
    end

    if weaponType == InventoryDefinitions.PrimaryWeaponTypeName then
        ownedWeapons = PlayerDataManager.getRifleSkins(player)
        equippedWeaponName = PlayerDataManager.getEquippedRifleSkin(player)
        PlayerDataManager.updateEquippedRifleSkin(player, weaponName)
    else
        ownedWeapons = PlayerDataManager.getPistolSkins(player)
        equippedWeaponName = PlayerDataManager.getEquippedPistolSkin(player)
        PlayerDataManager.updateEquippedPistolSkin(player, weaponName)
    end

    if not ownedWeapons then
        return false
    end

    inventory = inventory or SpawnInventory(player)
    local newWeapon: Tool = inventory:FindFirstChild(weaponName) or weaponTemplate:Clone()
    local currentWeapon: Tool? = equippedWeaponName and backpack:FindFirstChild(equippedWeaponName)

    if currentWeapon then
        currentWeapon.Parent = inventory
    end

    newWeapon.Parent = backpack
    return true
end

guiRemoteFunctions.TryEquipWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return InventoryManager.TryEquipWeapon(player, weaponName)
end)

guiRemoteFunctions.GetOwnedWeaponsFunction.OnServerInvoke = (function(player: Player)
    return InventoryManager.GetOwnedWeapons(player)
end)

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function()
        EquipOwnedWeapons(player)
    end)
end)

return InventoryManager