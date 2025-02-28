local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataManager: table = require(ServerScriptService.PlayerDataManager)
local InventoryDefinitions: {string} = require(ReplicatedStorage.Definitions.Inventory.InventoryDefinitions)
local weapons: Folder = ReplicatedStorage.Weapons
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local spawnEquippedWeaponConnections: {RBXScriptConnection} = {}
local InventoryManager: table = {}

function InventoryManager.SpawnEquippedWeapon(player: Player)
    local weaponName: string = PlayerDataManager.getEquippedRifleSkin(player)
    local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
    local weapon: Tool = weaponTemplate and weaponTemplate:Clone()

    if weapon then
        weapon.Parent = player.Backpack
        player.Character.Humanoid:EquipTool(weapon)
    end
end

function InventoryManager.DespawnEquippedWeapon(player: Player)
    for weapon: Tool in ipairs(player.Backpack) do
        weapon:Destroy()
    end
end

function InventoryManager.GetOwnedWeapons(player: Player): table
    local ownedWeapons: {[string]: {string}} =
    {
        [InventoryDefinitions.PrimaryWeaponTypeName] = PlayerDataManager.getRifleSkins(player),
    }

    return ownedWeapons
end

function InventoryManager.TryEquipWeapon(player: Player, weaponName: string): boolean
    local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)

    if not weaponTemplate then
        print(string.format("Weapon skin \"%s\" does not exist.", weaponName))
        return false
    end

    PlayerDataManager.updateEquippedRifleSkin(player, weaponName)
    ReplicatedStorage.Events.Inventory.WeaponEquippedEvent:FireClient(player, weaponName)

    return true
end

guiRemoteFunctions.TryEquipWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return InventoryManager.TryEquipWeapon(player, weaponName)
end)

guiRemoteFunctions.GetOwnedWeaponsFunction.OnServerInvoke = (function(player: Player)
    return InventoryManager.GetOwnedWeapons(player)
end)

guiRemoteFunctions.GetEquippedWeaponFunction.OnServerInvoke = (function(player: Player)
    return PlayerDataManager.getEquippedRifleSkin(player)
end)

guiRemoteFunctions.GetMoneyFunction.OnServerInvoke = (function(player: Player)
    return PlayerDataManager.getMoney(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
    if spawnEquippedWeaponConnections[player] then
        spawnEquippedWeaponConnections[player]:Disconnect()
        spawnEquippedWeaponConnections[player] = nil
    end
end)

ServerScriptService.BindableEvents.Match.MatchStartedEvent.Event:Connect(function(player: Player)
    InventoryManager.SpawnEquippedWeapon(player)

    spawnEquippedWeaponConnections[player] = player.CharacterAdded:Connect(function(_: Model)
        InventoryManager.SpawnEquippedWeapon(player)
    end)
end)

ServerScriptService.BindableEvents.Match.MatchEndedEvent.Event:Connect(function(player: Player)
    spawnEquippedWeaponConnections[player]:Disconnect()
    spawnEquippedWeaponConnections[player] = nil
    InventoryManager.DespawnEquippedWeapon(player)
end)

return InventoryManager