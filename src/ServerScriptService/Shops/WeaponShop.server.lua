local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--local DataManager: table = require(ServerScriptService.Modules.DataManager)
local PlayerDataManager: table = require(ServerScriptService.PlayerDataManager)
local weapons: Folder = ReplicatedStorage.Weapons
local shopGuiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui
local inventory: Folder

-- local function GetOwnedWeapons(player: Player): {[string]: {[string]: boolean}}
--     while not DataManager.Profiles[player] do
--         task.wait(1)
--     end

--     local profile: table = DataManager.Profiles[player]
--     local data: {[string]: any} = profile.Data

--     if not data["Weapons"] then
--         data["Weapons"] = {}
--     end

--     return data["Weapons"]
-- end

local function SpawnInventory(player: Player): Folder
    local newInventory = Instance.new("Folder")
    newInventory.Name = "Inventory"
    newInventory.Parent = player

    return newInventory
end

local function TryAddWeapon(player: Player, weaponName: string): string
    local weapon = weapons:FindFirstChild(weaponName)
    if weapon == nil then return false end

    local weaponType = weapon:GetAttribute("weaponType")
    if weaponType == nil then return false end

    --local profile: table = DataManager.Profiles[player]
    --local data: {[string]: any} = profile.Data
    --local ownedWeapons: {[string]: {[string]: boolean}} = data["Weapons"]
    local ownedWeapons: {[string]: {[string]: boolean}} =
    {
        ["Primary"] = PlayerDataManager.getRifleSkins(player),
        ["Secondary"] = PlayerDataManager.getPistolSkins(player)
    }
    local weaponVariants: {[string]: boolean} = ownedWeapons and ownedWeapons[weaponType] or nil
    local isOwned: boolean = weaponVariants and weaponVariants[weaponName] or nil

    if isOwned then
        return false
    -- elseif weaponVariants then
    --     weaponVariants[weaponName] = true
    -- elseif ownedWeapons then
    --     ownedWeapons[weaponType] = {[weaponName] = true}
    else
        --data["Weapons"] = {[weaponType] = {[weaponName] = true}}
        if weaponType == "Primary" then
            PlayerDataManager.addUnlockedRifleSkin(player, weaponName)
        else
            PlayerDataManager.addUnlockedPistolSkin(player, weaponName)
        end
    end

    return true, weaponType
end

-- local function TryEquipWeapon(player: Player, weaponName: string, weaponType: string): boolean
--     --local profile: table = DataManager.Profiles[player]
--     --local data: {[string]: any} = profile.Data
--     --local ownedWeapons: {[string]: {[string]: boolean}} = GetOwnedWeapons(player)
--     local ownedWeapons: {[string]: {[string]: boolean}} =
--     {
--         ["Primary"] = DataManager.getRifleSkins(player),
--         ["Secondary"] = DataManager.getPistolSkins(player)
--     }
--     --local equippedWeapons: {[string]: {[string]: boolean}} = data["Equipped"]
--     local equippedWeapons: {[string]: {[string]: boolean}} =
--     {
--         ["Primary"] = DataManager.getEquippedRifleSkin(player),
--         ["Secondary"] = DataManager.getEquippedPistolSkin(player),
--     }
--     local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
--     local backpack: Backpack = player.Backpack

--     if weaponTemplate then
--         inventory = inventory or SpawnInventory(player)
--         local weapon: Tool = inventory:FindFirstChild(weaponName) or weaponTemplate:Clone()

--         -- if not (ownedWeapons and ownedWeapons[weaponType] and ownedWeapons[weaponType][weaponName]) then
--         --     return false
--         -- end
--         if not (ownedWeapons and ownedWeapons[weaponType] and ownedWeapons[weaponType].Find(weaponName)) then
--             print("Returning false")
--             return false
--         end
--         print("Didn't return")

--         if equippedWeapons then
--             local currentWeaponName: string = equippedWeapons[weaponType]

--             if currentWeaponName then
--                 local currentWeapon: Tool = backpack:FindFirstChild(currentWeaponName)

--                 if currentWeapon then
--                     currentWeapon.Parent = inventory
--                 end
--             end

--             equippedWeapons[weaponType] = weaponName
--         else
--             equippedWeapons = {[weaponType] = weaponName}
--         end

--         weapon.Parent = backpack
--         return true
--     end

--     return false
-- end

local function TryEquipWeapon(player: Player, weaponName: string, weaponType: string): boolean
    local ownedWeapons: table
    local equippedWeaponName: string

    if weaponType == "Primary" then
        ownedWeapons = PlayerDataManager.getRifleSkins(player)
        equippedWeaponName = PlayerDataManager.getEquippedRifleSkin(player)
    else
        ownedWeapons = PlayerDataManager.getPistolSkins(player)
        equippedWeaponName = PlayerDataManager.getEquippedPistolSkin(player)
    end

    if not ownedWeapons then
        return false
    end

    local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
    local backpack: Backpack = player.Backpack

    if weaponTemplate then
        inventory = inventory or SpawnInventory(player)
        local weapon: Tool = inventory:FindFirstChild(weaponName) or weaponTemplate:Clone()

        local currentWeapon: Tool = backpack:FindFirstChild(equippedWeaponName)
        if currentWeapon then
            currentWeapon.Parent = inventory
        end

        weapon.Parent = backpack
        return true
    end

    return false
end

local function TryPurchaseWeapon(player: Player, weaponName: string): boolean
    local weapon: Tool = weapons:FindFirstChild(weaponName)
    if not weapon then
        print("Error: Weapon with given name does not exist.")
        return false
    end

    --local profile: table = DataManager.Profiles[player]
    --local data: {[string]: any} = profile.Data
    --local cash: number = data["Cash"]
    local money: number = PlayerDataManager.getMoney(player)
    local cost: number = weapon:GetAttribute("cost") or 0

    if money >= cost then
        local success: boolean, weaponType: string = TryAddWeapon(player, weaponName)

        if success then
            --cash -= cost
            PlayerDataManager.updateMoneyAdd(player, cost * -1)
            TryEquipWeapon(player, weaponName, weaponType)
            print("Success: " .. money .. " money remaining.")
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

-- local function GetEquippedWeapons(player: Player): {[string]: string}
--     while not DataManager.Profiles[player] do
--         task.wait(1)
--     end

--     local profile: table = DataManager.Profiles[player]
--     local data: {[string]: any} = profile.Data

--     if not data["Equipped"] then
--         data["Equipped"] = {}
--     end

--     return data["Equipped"]
-- end

-- local function EquipOwnedWeapons(player: Player)
--     local ownedWeapons: {[string]: {[string]: boolean}} = GetOwnedWeapons(player)
--     local equippedWeapons: {[string]: {[string]: string}} = GetEquippedWeapons(player)

--     inventory = Instance.new("Folder")
--     inventory.Name = "Inventory"
--     inventory.Parent = player

--     for _: string, weaponVariants: {[string]: boolean} in pairs(ownedWeapons) do
--         for weaponName: string, _: boolean in pairs(weaponVariants) do
--             local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
--             local weapon: Tool = weaponTemplate and weaponTemplate:Clone()

--             if weapon then
--                 weapon.Parent = inventory
--             end
--         end
--     end

--     for _: string, weaponName: string in pairs(equippedWeapons) do
--         local weapon = inventory:FindFirstChild(weaponName)

--         if weapon then
--             weapon.Parent = player.Backpack
--         end
--     end

--     if player.Backpack:FindFirstChildOfClass("Tool") then
--         player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChildOfClass("Tool"))
--     end
-- end

shopGuiRemoteFunctions.TryPurchaseWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return TryPurchaseWeapon(player, weaponName)
end)

shopGuiRemoteFunctions.GetOwnedWeaponsFunction.OnServerInvoke = (function(player: Player)
    --return GetOwnedWeapons(player)
end)

shopGuiRemoteFunctions.TryEquipWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    --return TryEquipWeapon(player, weaponName)
end)

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function()
        --EquipOwnedWeapons(player)
        -- for index, value in pairs(DataManager) do
        --     print(tostring(index) .. ": " .. tostring(value))
        -- end
    end)
end)