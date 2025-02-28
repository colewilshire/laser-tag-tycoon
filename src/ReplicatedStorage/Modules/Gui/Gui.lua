local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons: Folder = ReplicatedStorage.Weapons
local Gui: table =
{
    ["Guis"] = {}
}

local function GetGuiInfo(gui: PlayerGui): {[string]: any}
    return Gui["Guis"][gui]
end

local function SetActiveItemButton(gui: PlayerGui, weaponButtonFrame: Frame)
    if GetGuiInfo(gui)["ActiveItemButtonFrame"] then
        GetGuiInfo(gui)["ActiveItemButtonFrame"].OutlineFrame.Visible = false
    end

    GetGuiInfo(gui)["ActiveItemButtonFrame"] = weaponButtonFrame
    GetGuiInfo(gui)["ActiveItemButtonFrame"].OutlineFrame.Visible = true
end

function Gui.RegisterGui(gui: PlayerGui, activationButton: ImageButton, activationCondition: boolean, activationText: {[boolean]: string}, itemInfoFrame: Frame, scrollingFrame: ScrollingFrame, templateButtonFrame: Frame, weaponButtons: {[string]: ImageButton})
    Gui["Guis"][gui] =
    {
        ["ActivationButton"] = activationButton,
        ["ActivationCondition"] = activationCondition,
        ["ActivationText"] = activationText,
        ["ActiveItemButtonFrame"] = nil,
        ["ItemInfoFrame"] = itemInfoFrame,
        ["ScrollingFrame"] = scrollingFrame,
        ["TemplateButtonFrame"] = templateButtonFrame,
        ["WeaponButtons"] = weaponButtons
    }
end

function Gui.DisplayWeapon(gui: PlayerGui, weaponName: string)
    local guiInfo: {[string]: any} = Gui["Guis"][gui]
    local weaponButton: ImageButton = guiInfo["WeaponButtons"][weaponName]
    if not weaponButton then return end

    local weapon: Tool = weaponButton.Weapon.Value
    if not weapon then return end

    local attributes: {string: any} = weapon:GetAttributes()
    local itemDescription: string = attributes["description"] or
        string.format("Damage: %d\nFire Mode: %s\nMagazine Size: %d\nRange: %d\nRate of Fire: %d",
        attributes["damage"],
        attributes["fireMode"],
        attributes["magazineSize"],
        attributes["range"],
        attributes["rateOfFire"])

    local itemInfoFrame: Frame = guiInfo["ItemInfoFrame"]
    itemInfoFrame.ItemDescription.Text = itemDescription
    itemInfoFrame.ItemName.Text = attributes["displayName"] or weapon.Name
    itemInfoFrame.ItemImage.Image = weapon.TextureId
    itemInfoFrame.Visible = true

    local activationButton: ImageButton = guiInfo["ActivationButton"]
    if guiInfo["ActivationCondition"](weaponName) then
        activationButton.ActivationText.Text = guiInfo["ActivationText"][true]
        activationButton.Interactable = false
    else
        activationButton.ActivationText.Text = guiInfo["ActivationText"][false]
        activationButton.Interactable = true
    end

    SetActiveItemButton(gui, weaponButton.Parent)
end

function Gui.CreateWeaponButton(gui: PlayerGui, weaponName: string): ImageButton
    local guiInfo: {[string]: any} = Gui["Guis"][gui]
    local weapon: Tool = weapons:FindFirstChild(weaponName)
    if not weapon then return end

    local weaponButtonFrame: Frame = guiInfo["TemplateButtonFrame"]:Clone()
    local weaponButton: ImageButton = weaponButtonFrame.ItemButton

    weaponButtonFrame.Name = weapon.Name
    weaponButtonFrame.Parent = guiInfo["ScrollingFrame"]
    weaponButton.Image = weapon.TextureId
    weaponButtonFrame.Visible = true

    local weaponValue: ObjectValue = Instance.new("ObjectValue")
    weaponValue.Value = weapon
    weaponValue.Name = "Weapon"
    weaponValue.Parent = weaponButton

    weaponButton.Activated:Connect(function()
        Gui.DisplayWeapon(gui, weaponName)
    end)

    guiInfo["WeaponButtons"][weaponName] = weaponButton
    return weaponButton
end

function Gui.GetActiveWeaponButtonFrame(gui: PlayerGui): Frame
    return GetGuiInfo(gui)["ActiveItemButtonFrame"]
end

return Gui