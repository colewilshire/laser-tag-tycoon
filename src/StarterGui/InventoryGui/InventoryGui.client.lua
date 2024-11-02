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
local guiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui
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
    local itemDescription: string = ""

    itemDescription = itemDescription .. "Damage: " .. attributes["damage"] .. "\n"
    itemDescription = itemDescription .. "Fire Mode: " .. attributes["fireMode"] .. "\n"
    itemDescription = itemDescription .. "Magazine Size: " .. attributes["magazineSize"] .. "\n"
    itemDescription = itemDescription .. "Range: " .. attributes["range"] .. "\n"
    itemDescription = itemDescription .. "Rate of Fire: " .. attributes["rateOfFire"]

    if Players.LocalPlayer.Backpack:FindFirstChild(weapon.Name) then
        --itemInfoFrame.Cost.Text = "Already Owned"
        equipButton.EquipText.Text = "Equipped"
        equipButton.Interactable = false
    else
        --itemInfoFrame.Cost.Text = (attributes["cost"] or 0) .. " Cash"
        equipButton.EquipText.Text = "Equip"
        equipButton.Interactable = true
    end

    itemInfoFrame.ItemDescription.Text = itemDescription
    itemInfoFrame.ItemName.Text = weapon.Name
    itemInfoFrame.ItemImage.Image = weapon.TextureId
    itemInfoFrame.Visible = true
end

local function InitializeGui()
    for _: number, weapon: Tool in ipairs(weapons:GetChildren()) do
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
        local success: boolean = tryEquipWeaponFunction:InvokeServer(weaponName)

        if success then
            local weapon = weapons:FindFirstChild(weaponName)
            weapon:SetAttribute("owned", true)
            equippedWeaponName = weapon.Name
        end

        return success
    end

    return false
end

-- enableGuiEvent.OnClientEvent:Connect(function()
--     Open()
-- end)

-- disableGuiEvent.OnClientEvent:Connect(function()
--     Close()
-- end)

exitButton.Activated:Connect(function()
    Close()
end)

equipButton.Activated:Connect(function()
    TryEquipWeapon(activeItemButtonFrame.Name)
end)

UserInputService.InputBegan:Connect(function(inputObject: InputObject)
    if inputObject.KeyCode == Enum.KeyCode.I then
        if not gui.Enabled then
            Open()
        else
            Close()
        end
    end
end)

Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child: Instance)
    
end)

InitializeGui()