local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons: Folder = ReplicatedStorage.Weapons
local scripts: Folder = script.Parent
local shopGui: ScreenGui = scripts.Parent
local remoteEvents: Folder = scripts.Parent.RemoteEvents
local enableGuiEvent: RemoteEvent = remoteEvents.EnableGuiEvent
local disableGuiEvent: RemoteEvent = remoteEvents.DisableGuiEvent
local guiFrame: Frame = shopGui.GuiFrame
local exitButton: ImageButton = guiFrame.ExitButton
local shopFrame: Frame = guiFrame.ShopFrame
local itemInfoFrame: Frame = guiFrame.PurchaseFrame.ItemInfoFrame
local scrollingFrame: ScrollingFrame = shopFrame.ScrollingFrame
local templateButtonFrame: ImageButton = scrollingFrame.TemplateButtonFrame
local activeItemButtonFrame: Frame

local function HighlightActiveWeapon(weaponButtonFrame: Frame)
    if activeItemButtonFrame then
        activeItemButtonFrame.ItemButton.UIStroke.Enabled = false
    end

    activeItemButtonFrame = weaponButtonFrame
    activeItemButtonFrame.ItemButton.UIStroke.Enabled = true
end

local function DisplayWeapon(weapon: Model)
    local attributes: {string: any} = weapon:GetAttributes()
            local itemDescription: string = ""

            itemDescription = itemDescription .. "Damage: " .. attributes["damage"] .. "\n"
            itemDescription = itemDescription .. "Fire Mode: " .. attributes["fireMode"] .. "\n"
            itemDescription = itemDescription .. "Magazine Size: " .. attributes["magazineSize"] .. "\n"
            itemDescription = itemDescription .. "Range: " .. attributes["range"] .. "\n"
            itemDescription = itemDescription .. "Rate of Fire: " .. attributes["rateOfFire"]

            if attributes["owned"] then
                itemInfoFrame.Cost.Text = "Already Owned"
                itemInfoFrame.PurchaseButton.PurchaseText.Text = "Owned"
                itemInfoFrame.PurchaseButton.Interactable = false
            else
                itemInfoFrame.Cost.Text = (attributes["cost"] or 0) .. " Cash"
                itemInfoFrame.PurchaseButton.PurchaseText.Text = "Purchase"
                itemInfoFrame.PurchaseButton.Interactable = true
            end

            itemInfoFrame.ItemDescription.Text = itemDescription
            itemInfoFrame.ItemName.Text = weapon.Name
            itemInfoFrame.ItemImage.Image = weapon.TextureId
            itemInfoFrame.Visible = true
end

local function CreateItemButtons()
    for _: number, weapon: Model in ipairs(weapons:GetChildren()) do
        local weaponButtonFrame: Frame = templateButtonFrame:Clone()
        local weaponButton: ImageButton = weaponButtonFrame.ItemButton

        weaponButtonFrame.Name = weapon.Name
        weaponButtonFrame.Parent = scrollingFrame
        weaponButton.Image = weapon.TextureId
        weaponButtonFrame.Visible = true

        weaponButton.Activated:Connect(function()
            DisplayWeapon(weapon)
            HighlightActiveWeapon(weaponButtonFrame)
        end)

        weapon:GetAttributeChangedSignal("owned"):Connect(function()
            DisplayWeapon(weapon)
            HighlightActiveWeapon(weaponButtonFrame)
        end)
    end
end

local function OpenShop()
    shopGui.Enabled = true
end

local function CloseShop()
    shopGui.Enabled = false
    itemInfoFrame.Visible = false

    if activeItemButtonFrame then
        activeItemButtonFrame.ItemButton.UIStroke.Enabled = false
    end
end

local function TryPurchaseWeapon(weaponName: string): boolean
    if activeItemButtonFrame then
        local success: boolean = ReplicatedStorage.RemoteFunctions.ShopGui.TryPurchaseWeaponFunction:InvokeServer(weaponName)

        if success then
            print("Client-side success.")
            weapons:FindFirstChild(weaponName):SetAttribute("owned", true)
        else
            print("Client-side failure.")
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

itemInfoFrame.PurchaseButton.Activated:Connect(function()
    TryPurchaseWeapon(activeItemButtonFrame.Name)
end)

CreateItemButtons()