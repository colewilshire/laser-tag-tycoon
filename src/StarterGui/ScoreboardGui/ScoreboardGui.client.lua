local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local gui: ScreenGui = script.Parent.Parent
local guiFrame: Frame = gui.GuiFrame
local team1Frame: Frame = guiFrame.Team1Frame
local team2Frame: Frame = guiFrame.Team2Frame
local getScoredboardFunction: RemoteFunction = ReplicatedStorage.RemoteFunctions.Gui.GetScoredboardFunction
local clearScoreboardEvent: RemoteEvent = ReplicatedStorage.Events.Gui.ClearScoreboardEvent
local showScoreboardEvent: RemoteEvent = ReplicatedStorage.Events.Gui.ShowScoreboardEvent

local function Open(players: {[number]: table}?, teamScores: {[string]: number}?)
    if not players or not teamScores then
        players, teamScores = getScoredboardFunction:InvokeServer()
    end
    if not players or not teamScores then return end

    local team1: string, _: number = next(teamScores)

    for userId: number, playerDetails: table in pairs(players) do
        local playerEntry: Frame = team1Frame:FindFirstChild(userId) or team2Frame:FindFirstChild(userId)

        if not playerEntry then
            playerEntry = guiFrame.TemplateFrame:Clone()
            local portrait: ImageLabel = playerEntry.Portrait
            local displayName: TextLabel = playerEntry.DisplayName

            playerEntry.BackgroundColor3 = playerDetails["Color"]
            portrait.Image = Players:GetUserThumbnailAsync(playerDetails["CharacterAppearanceId"], 0, 0)
            displayName.Text = playerDetails["DisplayName"]
            playerEntry.Name = tostring(userId)
            playerEntry.Parent = playerDetails["Team"] == team1 and team1Frame or team2Frame
            playerEntry.Visible = true
        end

        local kills: TextLabel = playerEntry.Kills
        local deaths: TextLabel = playerEntry.Deaths

        kills.Text = playerDetails["Kills"]
        deaths.Text = playerDetails["Deaths"]
    end

    gui.Enabled = true
end

local function Close()
    gui.Enabled = false
end

local function ClearGui()
    for _: number, instance: Instance in ipairs(team1Frame:GetChildren()) do
        if instance:IsA("Frame") then
            instance:Destroy()
        end
    end

    for _: number, instance: Instance in ipairs(team2Frame:GetChildren()) do
        if instance:IsA("Frame") then
            instance:Destroy()
        end
    end
end

clearScoreboardEvent.OnClientEvent:Connect(ClearGui)

showScoreboardEvent.OnClientEvent:Connect(function(players: {[number]: table}, teamScores: {[string]: number})
    Open(players, teamScores)
end)

UserInputService.InputBegan:Connect(function(inputObject: InputObject)
    if inputObject.KeyCode == Enum.KeyCode.Tab or inputObject.KeyCode == Enum.KeyCode.ButtonSelect then
        if not gui.Enabled then
            Open()
        else
            Close()
        end
    end
end)