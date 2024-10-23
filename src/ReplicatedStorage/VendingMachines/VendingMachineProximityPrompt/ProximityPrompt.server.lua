local scripts: Folder = script.Parent
local vendingMachine: Model = scripts.Parent
local proximityPrompt: ProximityPrompt = vendingMachine.ProximityPrompt

proximityPrompt.Triggered:Connect(function(player: Player)
    player.PlayerGui.ShopGui.RemoteEvents.EnableGuiEvent:FireClient(player)
end)