local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons: Folder = ReplicatedStorage.Weapons
local scripts: Folder = script.Parent
local shopGui: ScreenGui = scripts.Parent
local remoteEvents: Folder = scripts.Parent.RemoteEvents
local enableGuiEvent: RemoteEvent = remoteEvents.EnableGuiEvent
local disableGuiEvent: RemoteEvent = remoteEvents.DisableGuiEvent
local guiFrame: Frame = shopGui.GuiFrame
local shopFrame: Frame = guiFrame.ShopFrame
local itemInfoFrame: Frame = guiFrame.PurchaseFrame.ItemInfoFrame
local scrollingFrame: ScrollingFrame = shopFrame.ScrollingFrame
local templateButton: ImageButton = scrollingFrame.TemplateButton

local function CreateItemButtons()
    for _: number, weapon: Model in ipairs(weapons:GetChildren()) do
        local weaponButton: ImageButton = templateButton:Clone()
        weaponButton.Name = weapon.Name
        weaponButton.Parent = scrollingFrame
        weaponButton.Visible = true

        weaponButton.Activated:Connect(function()
            local attributes: {string: any} = weapon:GetAttributes()
            itemInfoFrame.ItemName.Text = weapon.Name
            local s: string = ""
            for key:string, value: string in pairs(attributes) do
                s = s .. string.format("%s: %s\n", key, tostring(value))
            end
            itemInfoFrame.ItemDescription.Text = s
            itemInfoFrame.Visible = true
        end)
    end
end

local function OpenShop()
    shopGui.Enabled = true
end

local function CloseShop()
    shopGui.Enabled = false
    itemInfoFrame.Visible = false
end

enableGuiEvent.OnClientEvent:Connect(function()
    OpenShop()
end)

disableGuiEvent.OnClientEvent:Connect(function()
    CloseShop()
end)

CreateItemButtons()