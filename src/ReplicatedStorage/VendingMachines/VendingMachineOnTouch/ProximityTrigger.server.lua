local Players = game:GetService("Players")
local scripts: Folder = script.Parent
local vendingMachine: Model = scripts.Parent
local proximityTrigger: Part = vendingMachine.ProximityTrigger
local hitbox: Part = proximityTrigger.Hitbox

hitbox.Touched:Connect(function(otherPart: BasePart)
    local character: Model = otherPart.Parent
    local player: Player = Players:GetPlayerFromCharacter(character)

    if player and otherPart.Name == "HumanoidRootPart" then
        player.PlayerGui.ShopGui.RemoteEvents.EnableGuiEvent:FireClient(player)
    end
end)

hitbox.TouchEnded:Connect(function(otherPart: BasePart)
    local character: Model = otherPart.Parent
    local player: Player = Players:GetPlayerFromCharacter(character)

    if player and otherPart.Name == "HumanoidRootPart" then
        player.PlayerGui.ShopGui.RemoteEvents.DisableGuiEvent:FireClient(player)
    end
end)