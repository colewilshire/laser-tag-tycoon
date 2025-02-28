local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Gui: table = require(ReplicatedStorage.Modules.Gui.Gui)
local Inventory: table = require(ReplicatedStorage.Modules.Inventory.Inventory)
local gui: ScreenGui = script.Parent.Parent
local guiFrame: Frame = gui.GuiFrame
local exitButton: ImageButton = guiFrame.ExitButton
local inventoryFrame: Frame = guiFrame.BackgroundFrame.InventoryFrame
local itemInfoFrame: Frame = guiFrame.EquipFrame.ItemInfoFrame
local equipButton: ImageButton = itemInfoFrame.EquipButtonFrame.EquipButton
local moneyText: TextLabel = inventoryFrame.Money
local scrollingFrame: ScrollingFrame = inventoryFrame.ScrollingFrame
local templateButtonFrame: ImageButton = scrollingFrame.TemplateButtonFrame
local inventoryEvents: Folder = ReplicatedStorage.Events.Inventory
local equipmentUpdatedEvent: BindableEvent = inventoryEvents.EquipmentUpdatedEvent
local moneyUpdatedEvent: BindableEvent = inventoryEvents.MoneyUpdatedEvent
local weaponButtons: {[string]: ImageButton} = {}
local activationText: {[boolean]: string} =
{
    [true] = "Equipped",
    [false] = "Equip"
}

local function TryGetWeaponButton(weaponName: string): ImageButton
    local weaponButton: ImageButton = weaponButtons[weaponName]

    if not weaponButton then
        weaponButton = Gui.CreateWeaponButton(gui, weaponName)
    end

    return weaponButton
end

local function InitializeGui()
    Gui.RegisterGui(gui, equipButton, Inventory.IsEquippedWeapon, activationText, itemInfoFrame, scrollingFrame, templateButtonFrame, weaponButtons)

    for weaponName: string, _: boolean in pairs(Inventory.GetOwnedWeapons()) do
        Gui.CreateWeaponButton(gui, weaponName)
    end

    moneyText.Text = string.format("<font color =\"#AAAAFF\">%s</font>%i", utf8.char(0xE002), Inventory.GetMoney())

    equipmentUpdatedEvent.Event:Connect(function(equippedWeaponName: string)
        local weaponButton: ImageButton = TryGetWeaponButton(equippedWeaponName)
        Gui.DisplayWeapon(gui, equippedWeaponName)
    end)

    moneyUpdatedEvent.Event:Connect(function(currentPlayerMoney: number)
        moneyText.Text = string.format("<font color =\"#AAAAFF\">%s</font>%i", utf8.char(0xE002), currentPlayerMoney)
    end)
end

local function Open()
    Gui.DisplayWeapon(gui, Inventory.GetEquippedWeaponName())
    gui.Enabled = true
end

local function Close()
    gui.Enabled = false
    itemInfoFrame.Visible = false

    if Gui.GetActiveWeaponButtonFrame(gui) then
        Gui.GetActiveWeaponButtonFrame(gui).OutlineFrame.Visible = false
    end
end

exitButton.Activated:Connect(function()
    Close()
end)

equipButton.Activated:Connect(function()
    if Inventory.TryEquipWeapon(Gui.GetActiveWeaponButtonFrame(gui).Name) then
        Gui.DisplayWeapon(gui, Gui.GetActiveWeaponButtonFrame(gui).Name)
    end
end)

UserInputService.InputBegan:Connect(function(inputObject: InputObject)
    if Players.LocalPlayer.Team.Name ~= "Lobby" then return end

    if inputObject.KeyCode == Enum.KeyCode.I or inputObject.KeyCode == Enum.KeyCode.ButtonSelect then
        if not gui.Enabled then
            Open()
        else
            Close()
        end
    end
end)

InitializeGui()