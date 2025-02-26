local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons: Folder = ReplicatedStorage.Weapons
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local getOwnedWeaponsFunction: RemoteFunction = guiRemoteFunctions.GetOwnedWeaponsFunction
local Inventory: table = {}

local function GetOwnedWeapons(): {[string]: {string}}
    local ownedWeapons: {[string]: {string}} = getOwnedWeaponsFunction:InvokeServer()

    for _: string, weaponVariants: {string} in pairs(ownedWeapons) do
        for _: number, weaponName: string in pairs(weaponVariants) do
            local weapon: Tool = weapons:FindFirstChild(weaponName)

            if weapon then
                weapon:SetAttribute("owned", true)
            end
        end
    end

    return ownedWeapons
end

function Inventory.GetOwnedWeapons()
    return Inventory["OwnedWeapons"]
end

function Inventory.EnableBackpack(player: Player, equippedToolName: string?)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

    if equippedToolName then
        local weaponToEquip: Tool = player.Backpack:FindFirstChild(equippedToolName)

        if weaponToEquip then
            player.Character.Humanoid:EquipTool(weaponToEquip)
        end
    end
end

function Inventory.DisableBackpack(player: Player): string?
    local character: Model = player.Character
    local equippedWeapon: Tool = character:FindFirstChildOfClass("Tool") or {}

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    character.Humanoid:UnequipTools()

    return equippedWeapon["Name"]
end

--Inventory["OwnedWeapons"] = GetOwnedWeapons()

return Inventory