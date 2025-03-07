local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local matchEvents: Folder = ServerScriptService.BindableEvents.Match
local matchStartedEvent: BindableEvent = matchEvents.MatchStartedEvent
local guiEvents: Folder = ReplicatedStorage.Events.Gui
local closeGuiEvent: RemoteEvent = guiEvents.CloseGuiEvent
local clearScoreboardEvent: RemoteEvent = guiEvents.ClearScoreboardEvent

matchStartedEvent.Event:Connect(function(player: Player)
    closeGuiEvent:FireClient(player)
    clearScoreboardEvent:FireClient(player)
end)