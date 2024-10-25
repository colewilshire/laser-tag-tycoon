local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local weapons: Folder = ReplicatedStorage.Weapons
local scripts: Folder = script.Parent
local shopGui: ScreenGui = scripts.Parent
local remoteEvents: Folder = shopGui.RemoteEvents
local enableGuiEvent: RemoteEvent = remoteEvents.EnableGuiEvent
local disableGuiEvent: RemoteEvent = remoteEvents.DisableGuiEvent
local guiFrame: Frame = shopGui.GuiFrame
local exitButton: ImageButton = guiFrame.ExitButton
local shopFrame: Frame = guiFrame.BackgroundFrame.ShopFrame
local itemInfoFrame: Frame = guiFrame.PurchaseFrame.ItemInfoFrame
local purchaseButton: ImageButton = itemInfoFrame.PurchaseButtonFrame.PurchaseButton
local scrollingFrame: ScrollingFrame = shopFrame.ScrollingFrame
local templateButtonFrame: ImageButton = scrollingFrame.TemplateButtonFrame
local shopGuiRemoteFunctions: Folder = ReplicatedStorage.RemoteFunctions.ShopGui
local tryPurchaseWeaponFunction: RemoteFunction = shopGuiRemoteFunctions. TryPurchaseWeaponFunction
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

    if attributes["owned"] then
        itemInfoFrame.Cost.Text = "Already Owned"
        purchaseButton.PurchaseText.Text = "Owned"
        purchaseButton.Interactable = false
    else
        itemInfoFrame.Cost.Text = (attributes["cost"] or 0) .. " Cash"
        purchaseButton.PurchaseText.Text = "Purchase"
        purchaseButton.Interactable = true
    end

    itemInfoFrame.ItemDescription.Text = itemDescription
    itemInfoFrame.ItemName.Text = weapon.Name
    itemInfoFrame.ItemImage.Image = weapon.TextureId
    itemInfoFrame.Visible = true
end

local function CreateItemButtons()
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
            if shopGui.Enabled then
                DisplayWeapon(weapon)
                SetActiveItemButton(weaponButtonFrame)
            end
        end)
    end
end

local function EnableBackpack()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

    if equippedWeaponName then
        local player: Player = Players.LocalPlayer
        local weaponToEquip: Tool = player.Backpack:FindFirstChild(equippedWeaponName)

        if weaponToEquip then
            player.Character.Humanoid:EquipTool(weaponToEquip)
        end
    end
end

local function DisableBackpack()
    local character: Model = Players.LocalPlayer.Character
    local equippedWeapon: Tool = character:FindFirstChildOfClass("Tool")

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    equippedWeaponName = equippedWeapon and equippedWeapon.Name or nil
    character.Humanoid:UnequipTools()
end

local function OpenShop()
    shopGui.Enabled = true
    DisableBackpack()
end

local function CloseShop()
    shopGui.Enabled = false
    itemInfoFrame.Visible = false
    EnableBackpack()

    if activeItemButtonFrame then
        activeItemButtonFrame.OutlineFrame.Visible = false
    end
end

local function TryPurchaseWeapon(weaponName: string): boolean
    if activeItemButtonFrame then
        local success: boolean = tryPurchaseWeaponFunction:InvokeServer(weaponName)

        if success then
            local weapon = weapons:FindFirstChild(weaponName)
            equippedWeaponName = weapon.Name
        end

        return success
    end
end

enableGuiEvent.OnClientEvent:Connect(function()
    OpenShop()
end)

disableGuiEvent.OnClientEvent:Connect(function()
    CloseShop()
end)

exitButton.Activated:Connect(function()
    CloseShop()
end)

purchaseButton.Activated:Connect(function()
    TryPurchaseWeapon(activeItemButtonFrame.Name)
end)

Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child: Instance)
    local weapon: Tool = weapons:FindFirstChild(child.Name)

    if weapon then
        weapon:SetAttribute("owned", true)
    end
end)

CreateItemButtons()