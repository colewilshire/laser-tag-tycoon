local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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

local function DisplayWeapon(weapon)
    local attributes: {string: any} = weapon:GetAttributes()
    local itemDescription: string = attributes["description"] or
        string.format("Damage: %d\nFire Mode: %s\nMagazine Size: %d\nRange: %d\nRate of Fire: %d",
        attributes["damage"],
        attributes["fireMode"],
        attributes["magazineSize"],
        attributes["range"],
        attributes["rateOfFire"])

    if weapon.Name == equippedWeaponName then
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

local function CreateWeaponButton(weaponName: string)
    local weapon: Tool = weapons:FindFirstChild(weaponName)
    if not weapon then return end
    weapon:SetAttribute("owned", true)

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
end

local function InitializeGui()
    equippedWeaponName = ReplicatedStorage.RemoteFunctions.Gui.GetEquippedWeaponFunction:InvokeServer()

    for _: number, weaponName: string in ipairs(ReplicatedStorage.RemoteFunctions.Gui.GetOwnedWeaponsFunction:InvokeServer()["Primary"]) do
        CreateWeaponButton(weaponName)
    end

    ReplicatedStorage.Events.Inventory.WeaponPurchasedEvent.OnClientEvent:Connect(function(weaponName: string)
        CreateWeaponButton(weaponName)
    end)

    ReplicatedStorage.Events.Inventory.WeaponEquippedEvent.OnClientEvent:Connect(function(weaponName: string)
        equippedWeaponName = weaponName

        if gui.Enabled == true then
            local weapon: Tool = weapons:FindFirstChild(weaponName)

            if weapon then
                DisplayWeapon(weapon)
            end
        end
    end)
end

local function Open()
    gui.Enabled = true
end

local function Close()
    gui.Enabled = false
    itemInfoFrame.Visible = false

    if activeItemButtonFrame then
        activeItemButtonFrame.OutlineFrame.Visible = false
    end
end

local function TryEquipWeapon(weaponName: string): boolean
    if activeItemButtonFrame then
        return tryEquipWeaponFunction:InvokeServer(weaponName)
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