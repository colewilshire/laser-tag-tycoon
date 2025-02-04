local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Inventory = require(ReplicatedStorage.Modules.Inventory.Inventory)
local weapons: Folder = ReplicatedStorage.Weapons
local scripts: Folder = script.Parent
local gui: ScreenGui = scripts.Parent
local guiFrame: Frame = gui.GuiFrame
local exitButton: ImageButton = guiFrame.ExitButton
local inventoryFrame: Frame = guiFrame.BackgroundFrame.InventoryFrame
local itemInfoFrame: Frame = guiFrame.EquipFrame.ItemInfoFrame
local equipButton: ImageButton = itemInfoFrame.EquipButtonFrame.EquipButton
local scrollingFrame: ScrollingFrame = inventoryFrame.ScrollingFrame
local templateButtonFrame: ImageButton = scrollingFrame.TemplateButtonFrame
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local tryEquipWeaponFunction: RemoteFunction = guiRemoteFunctions.TryEquipWeaponFunction
local activeItemButtonFrame: Frame
local equippedWeaponName: string

local function SetActiveItemButton(weaponButtonFrame: Frame)
    if activeItemButtonFrame then
        activeItemButtonFrame.OutlineFrame.Visible = false
    end

    activeItemButtonFrame = weaponButtonFrame
    activeItemButtonFrame.OutlineFrame.Visible = true
end

local function DisplayWeapon(weapon: Tool)
    local attributes: {string: any} = weapon:GetAttributes()
    local itemDescription: string = attributes["description"] or
        string.format("Damage: %d\nFire Mode: %s\nMagazine Size: %d\nRange: %d\nRate of Fire: %d",
        attributes["damage"],
        attributes["fireMode"],
        attributes["magazineSize"],
        attributes["range"],
        attributes["rateOfFire"])

    if Players.LocalPlayer.Backpack:FindFirstChild(weapon.Name) then
        equipButton.EquipText.Text = "Equipped"
        equipButton.Interactable = false
    else
        equipButton.EquipText.Text = "Equip"
        equipButton.Interactable = true
    end

    itemInfoFrame.ItemDescription.Text = itemDescription
    itemInfoFrame.ItemName.Text = attributes["displayName"] or weapon.Name
    itemInfoFrame.ItemImage.Image = weapon.TextureId
    itemInfoFrame.Visible = true
end

local function CreateWeaponButton(weapon: Tool)
    local weaponButtonFrame: Frame = templateButtonFrame:Clone()
    local weaponButton: ImageButton = weaponButtonFrame.ItemButton

    weaponButtonFrame.Name = weapon.Name
    weaponButtonFrame.Parent = scrollingFrame
    weaponButton.Image = weapon.TextureId
    weaponButtonFrame.Visible = true

    weaponButton.Activated:Connect(function()
        DisplayWeapon(weapon)
        SetActiveItemButton(weaponButtonFrame)
    end)

    weapon:GetAttributeChangedSignal("equipped"):Connect(function()
        if gui.Enabled and weapon:GetAttribute("equipped") == true then
            DisplayWeapon(weapon)
            SetActiveItemButton(weaponButtonFrame)
        end
    end)
end

local function InitializeGui()
    for _: number, weapon: Tool in ipairs(weapons:GetChildren()) do
        if weapon:GetAttribute("owned") == true then
            CreateWeaponButton(weapon)
        end

        weapon:GetAttributeChangedSignal("owned"):Connect(function()
            CreateWeaponButton(weapon)
        end)
    end
end

local function Open()
    gui.Enabled = true
    equippedWeaponName = Inventory.DisableBackpack(Players.LocalPlayer)
end

local function Close()
    gui.Enabled = false
    itemInfoFrame.Visible = false
    Inventory.EnableBackpack(Players.LocalPlayer, equippedWeaponName)

    if activeItemButtonFrame then
        activeItemButtonFrame.OutlineFrame.Visible = false
    end
end

local function TryEquipWeapon(weaponName: string): boolean
    if activeItemButtonFrame then
        local success: boolean, newWeapon: Tool, previousWeapon: Tool = tryEquipWeaponFunction:InvokeServer(weaponName)

        if success then
            local newWeaponTemplate: Tool = weapons:FindFirstChild(newWeapon.Name)
            local previousWeaponTemplate: Tool = weapons:FindFirstChild(previousWeapon.Name)

            equippedWeaponName = newWeapon.Name
            newWeaponTemplate:SetAttribute("equipped", true)
            previousWeaponTemplate:SetAttribute("equipped", nil)
        end

        return success
    end

    return false
end

exitButton.Activated:Connect(function()
    Close()
end)

equipButton.Activated:Connect(function()
    TryEquipWeapon(activeItemButtonFrame.Name)
end)

UserInputService.InputBegan:Connect(function(inputObject: InputObject)
    if inputObject.KeyCode == Enum.KeyCode.I or inputObject.KeyCode == Enum.KeyCode.ButtonSelect then
        if not gui.Enabled then
            Open()
        else
            Close()
        end
    end
end)

InitializeGui()