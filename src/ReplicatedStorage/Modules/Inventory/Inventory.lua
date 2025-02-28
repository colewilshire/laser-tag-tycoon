local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons: Folder = ReplicatedStorage.Weapons
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local getOwnedWeaponsFunction: RemoteFunction = guiRemoteFunctions.GetOwnedWeaponsFunction
local getEquippedWeaponsFunction: RemoteFunction = guiRemoteFunctions.GetEquippedWeaponFunction
local getMoneyFunction: RemoteFunction = guiRemoteFunctions.GetMoneyFunction
local tryEquipWeaponFunction: RemoteFunction = guiRemoteFunctions.TryEquipWeaponFunction
local tryPurchaseWeaponFunction: RemoteFunction = guiRemoteFunctions.TryPurchaseWeaponFunction
local inventoryEvents: Folder = ReplicatedStorage.Events.Inventory
local weaponPurchasedEvent: RemoteEvent = inventoryEvents.WeaponPurchasedEvent
local equipmentUpdatedEvent: BindableEvent = inventoryEvents.EquipmentUpdatedEvent
local moneyUpdatedEvent: BindableEvent = inventoryEvents.MoneyUpdatedEvent
local Inventory: table =
{
    ["OwnedWeapons"] = {},
    ["EquippedWeapon"] = nil,
    ["Money"] = 0
}

local function RegisterOwnedWeapon(weaponName: string)
    local weapon: Tool = weapons:FindFirstChild(weaponName)

    if weapon then
        Inventory["OwnedWeapons"][weaponName] = true
        weapon:SetAttribute("owned", true)
    end
end

local function InitializeInventory()
    for _: number, weaponName: string in ipairs(getOwnedWeaponsFunction:InvokeServer()["Primary"]) do
        RegisterOwnedWeapon(weaponName)
    end

    Inventory["EquippedWeapon"] = getEquippedWeaponsFunction:InvokeServer()
    Inventory["Money"] = getMoneyFunction:InvokeServer()

    weaponPurchasedEvent.OnClientEvent:Connect(function(weaponName: string, currentPlayerMoney: number)
        RegisterOwnedWeapon(weaponName)
        Inventory["Money"] = currentPlayerMoney
        moneyUpdatedEvent:Fire(currentPlayerMoney)
    end)
end

function Inventory.GetOwnedWeapons(): {[string]: boolean}
    return Inventory["OwnedWeapons"]
end

function Inventory.GetEquippedWeaponName(): string
    return Inventory["EquippedWeapon"]
end

function Inventory.IsEquippedWeapon(weaponName: string): boolean
    return Inventory.GetEquippedWeaponName() == weaponName
end

function Inventory.GetMoney(): number
    return Inventory["Money"]
end

function Inventory.OwnsWeapon(weaponName: string): boolean
    return Inventory.GetOwnedWeapons()[weaponName]
end

function Inventory.TryEquipWeapon(weaponName: string?): boolean
    if weaponName then
        local success: boolean = tryEquipWeaponFunction:InvokeServer(weaponName)

        if success then
            Inventory["EquippedWeapon"] = weaponName
            equipmentUpdatedEvent:Fire(weaponName)

            return success
        end
    end

    return false
end

function Inventory.TryPurchaseWeapon(weaponName: string?): boolean
    if weaponName then
        local success: boolean = tryPurchaseWeaponFunction:InvokeServer(weaponName)

        if success then
            Inventory["EquippedWeapon"] = weaponName
            equipmentUpdatedEvent:Fire(weaponName)

            return success
        end
    end

    return false
end

InitializeInventory()

return Inventory