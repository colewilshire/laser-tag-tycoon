local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local matchEvents: Folder = ServerScriptService.BindableEvents.Match
local matchStartedEvent: BindableEvent = matchEvents.MatchStartedEvent
local matchEndedEvent: BindableEvent = matchEvents.MatchEndedEvent
local guiEvents: Folder = ReplicatedStorage.Events.Gui
local closeGuiEvent: RemoteEvent = guiEvents.CloseGuiEvent

matchStartedEvent.Event:Connect(function(player: Player)
    closeGuiEvent:FireClient(player)
end)

matchEndedEvent.Event:Connect(function(player: Player)
    closeGuiEvent:FireClient(player)
end)