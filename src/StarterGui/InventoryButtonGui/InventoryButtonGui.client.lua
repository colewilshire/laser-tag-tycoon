local Players =game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local scripts: Folder = script.Parent
local gui: ScreenGui = scripts.Parent
local inventoryButton: ImageButton = gui.GuiFrame.ButtonFrame.InventoryButton
local inventoryGui: ScreenGui = Players.LocalPlayer.PlayerGui:WaitForChild("InventoryGui")

inventoryButton.Activated:Connect(function()
    if not inventoryGui.Enabled then
        inventoryGui.Enabled = true
    else
        inventoryGui.Enabled = false
    end
end)

if UserInputService.TouchEnabled then
    gui.Enabled = true
end