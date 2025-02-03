local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Inventory = require(ReplicatedStorage.Modules.Inventory.Inventory)
local weapons: Folder = ReplicatedStorage.Weapons
local scripts: Folder = script.Parent
local gui: ScreenGui = scripts.Parent
local remoteEvents: Folder = gui.RemoteEvents
local enableGuiEvent: RemoteEvent = remoteEvents.EnableGuiEvent
local disableGuiEvent: RemoteEvent = remoteEvents.DisableGuiEvent
local guiFrame: Frame = gui.GuiFrame
local exitButton: ImageButton = guiFrame.ExitButton
local shopFrame: Frame = guiFrame.BackgroundFrame.ShopFrame
local itemInfoFrame: Frame = guiFrame.PurchaseFrame.ItemInfoFrame
local purchaseButton: ImageButton = itemInfoFrame.PurchaseButtonFrame.PurchaseButton
local scrollingFrame: ScrollingFrame = shopFrame.ScrollingFrame
local templateButtonFrame: ImageButton = scrollingFrame.TemplateButtonFrame
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.Gui
local tryPurchaseWeaponFunction: RemoteFunction = guiRemoteFunctions.TryPurchaseWeaponFunction
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

    if attributes["owned"] then
        itemInfoFrame.Cost.Text = "Already Owned"
        purchaseButton.PurchaseText.Text = "Owned"
        purchaseButton.Interactable = false
    else
        itemInfoFrame.Cost.Text = (attributes["cost"] or 0) .. " Money"
        purchaseButton.PurchaseText.Text = "Purchase"
        purchaseButton.Interactable = true
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

    weapon:GetAttributeChangedSignal("owned"):Connect(function()
        if gui.Enabled then
            DisplayWeapon(weapon)
            SetActiveItemButton(weaponButtonFrame)
        end
    end)
end

local function InitializeGui()
    for _: number, weapon: Tool in ipairs(weapons:GetChildren()) do
        CreateWeaponButton(weapon)
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

local function TryPurchaseWeapon(weaponName: string): boolean
    if activeItemButtonFrame then
        local success: boolean = tryPurchaseWeaponFunction:InvokeServer(weaponName)

        if success then
            local weapon = weapons:FindFirstChild(weaponName)
            weapon:SetAttribute("owned", true)
            equippedWeaponName = weapon.Name
        end

        return success
    end

    return false
end

enableGuiEvent.OnClientEvent:Connect(function()
    Open()
end)

disableGuiEvent.OnClientEvent:Connect(function()
    Close()
end)

exitButton.Activated:Connect(function()
    Close()
end)

purchaseButton.Activated:Connect(function()
    TryPurchaseWeapon(activeItemButtonFrame.Name)
end)

InitializeGui()