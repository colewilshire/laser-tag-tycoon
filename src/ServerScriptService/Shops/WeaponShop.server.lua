local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local dataManager: table = require(ServerScriptService.Modules.DataManager)
local weapons: Folder = ReplicatedStorage.Weapons
local shopGuiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui
local shadowBackpack: Folder

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
    local backpack: Backpack = player.Backpack

    if weaponTemplate then
        local weapon: Tool = shadowBackpack:FindFirstChild(weaponName) or weaponTemplate:Clone()
        local weaponType: string = weapon:GetAttribute("weaponType")

        if equippedWeapons then
            local currentWeaponName: string = equippedWeapons[weaponType]

            if currentWeaponName then
                local currentWeapon: Tool = backpack:FindFirstChild(currentWeaponName)

                if currentWeapon then
                    currentWeapon.Parent = shadowBackpack
                end
            end

            equippedWeapons[weaponType] = weaponName
        else
            equippedWeapons = {[weaponType] = weaponName}
        end

        weapon.Parent = backpack
    end
end

local function EquipWeaponFromShadowBackpack(player: Player, weaponName: string)
    local profile: table = dataManager.Profiles[player]
    local data: {[string]: any} = profile.Data
    local equippedWeapons: {[string]: {[string]: boolean}} = data["Equipped"]
    local weapon: Tool = shadowBackpack:FindFirstChild(weaponName)
    local backpack: Backpack = player.Backpack

    if weapon then
        --local weapon: Tool = weaponTemplate:Clone()
        local weaponType: string = weapon:GetAttribute("weaponType")

        if equippedWeapons then
            local currentWeaponName: string = equippedWeapons[weaponType]
            local currentWeapon: Tool = currentWeaponName and backpack:FindFirstChild(currentWeaponName)

            if currentWeapon then
                --currentWeapon:Destroy()
                currentWeapon.Parent = shadowBackpack
            end

            equippedWeapons[weaponType] = weaponName
        else
            equippedWeapons = {[weaponType] = weaponName}
        end

        weapon.Parent = backpack
    end
end

-- local function EquipWeaponFromShadowBackpack(player: Player, weaponName: string)
--     local weapon = shadowBackpack:FindFirstChild(weaponName)

--     if weapon then
--         weapon.Parent = player.Backpack
--     end
-- end

local function TryEquipWeapon(player: Player, weaponName: string)

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

local function GetOwnedWeapons(player: Player): {[string]: {[string]: boolean}}
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

local function EquipOwnedWeapons(player: Player)
    local ownedWeapons: {[string]: {[string]: boolean}} = GetOwnedWeapons(player)
    local equippedWeapons: {[string]: {[string]: string}} = GetEquippedWeapons(player)

    shadowBackpack = Instance.new("Folder")
    shadowBackpack.Name = "ShadowBackpack"
    shadowBackpack.Parent = player

    for _: string, weaponVariants: {[string]: boolean} in pairs(ownedWeapons) do
        for weaponName: string, _: boolean in pairs(weaponVariants) do
            local weaponTemplate: Tool = weapons:FindFirstChild(weaponName)
            local weapon: Tool = weaponTemplate and weaponTemplate:Clone()

            if weapon then
                weapon.Parent = shadowBackpack
            end
        end
    end

    for _: string, weaponName: string in pairs(equippedWeapons) do
        local weapon = shadowBackpack:FindFirstChild(weaponName)

        if weapon then
            weapon.Parent = player.Backpack
        end
    end

    if player.Backpack:FindFirstChildOfClass("Tool") then
        player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChildOfClass("Tool"))
    end
end

shopGuiRemoteFunctions.TryPurchaseWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    return TryPurchaseWeapon(player, weaponName)
end)

shopGuiRemoteFunctions.GetOwnedWeaponsFunction.OnServerInvoke = (function(player: Player)
    return GetOwnedWeapons(player)
end)

shopGuiRemoteFunctions.TryEquipWeaponFunction.OnServerInvoke = (function(player: Player, weaponName: string)
    EquipWeapon(player, weaponName)
end)

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function()
        --EquipEquippedWeapons(player)
        EquipOwnedWeapons(player)
    end)
end)