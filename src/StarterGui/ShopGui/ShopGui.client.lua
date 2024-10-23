local scripts: Folder = script.Parent
local shopGui: ScreenGui = scripts.Parent
local remoteEvents: Folder = scripts.Parent.RemoteEvents
local enableGuiEvent: RemoteEvent = remoteEvents.EnableGuiEvent
local disableGuiEvent: RemoteEvent = remoteEvents.DisableGuiEvent

enableGuiEvent.OnClientEvent:Connect(function()
    shopGui.Enabled = true
end)

disableGuiEvent.OnClientEvent:Connect(function()
    shopGui.Enabled = false
end)