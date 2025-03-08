local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local gui: ScreenGui = script.Parent.Parent
local playerScoreFrame: Frame = gui.PlayerScoreFrame
local teamScoreFrame: Frame = gui.TeamScoreFrame
local team1Frame: Frame = playerScoreFrame.Team1Frame
local team2Frame: Frame = playerScoreFrame.Team2Frame
local getScoredboardFunction: RemoteFunction = ReplicatedStorage.RemoteFunctions.Gui.GetScoredboardFunction
local clearScoreboardEvent: RemoteEvent = ReplicatedStorage.Events.Gui.ClearScoreboardEvent
local showScoreboardEvent: RemoteEvent = ReplicatedStorage.Events.Gui.ShowScoreboardEvent

local function Open(players: {[number]: table}?, teamScores: {[string]: number}?, endOfMatch: boolean?)
    if not players or not teamScores then
        players, teamScores = getScoredboardFunction:InvokeServer()
    end
    if not players or not teamScores then return end

    local team1: string, team1Score: number = next(teamScores)
    local team2: string, team2Score: number = next(teamScores, team1)
    local leadingTeam: string?

    if team1Score > team2Score then
        leadingTeam = team1
    elseif team2Score > team1Score then
        leadingTeam = team2
    end

    for userId: number, playerDetails: table in pairs(players) do
        local playerEntry: Frame = team1Frame:FindFirstChild(userId) or team2Frame:FindFirstChild(userId)

        if not playerEntry then
            playerEntry = playerScoreFrame.PlayerDetailsTemplateFrame:Clone()
            local portrait: ImageLabel = playerEntry.Portrait
            local displayName: TextLabel = playerEntry.DisplayName
            local color: Color3 = playerDetails["Color"]
            local halfColor: Color3 = Color3.new(color.R * .5, color.G * .5, color.B * .5)

            playerEntry.BackgroundColor3 = color
            playerEntry.Kills.BackgroundColor3 = halfColor
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

    for teamName: string, teamScore: number in pairs(teamScores) do
        local teamEntry: Frame = teamScoreFrame:FindFirstChild(teamName)

        if not teamEntry then
            teamEntry = teamScoreFrame.TeamDetailsTemplateFrame:Clone()
            local displayName: TextLabel = teamEntry.DisplayName
            local team: Team = Teams:FindFirstChild(teamName)
            local color: Color3 = team.TeamColor.Color
            local halfColor: Color3 = Color3.new(color.R * .5, color.G * .5, color.B * .5)

            displayName.Text = teamName
            teamEntry.BackgroundColor3 = color
            teamEntry.Score.BackgroundColor3 = halfColor
            teamEntry.Name = teamName
            teamEntry.Parent = teamScoreFrame
            teamEntry.Visible = true
        end

        local score: TextLabel = teamEntry.Score
        local place: TextLabel = teamEntry.Place
        score.Text = teamScore

        if leadingTeam then
            if teamName == leadingTeam then
                place.Text = 1
                teamEntry.LayoutOrder = 0

                if endOfMatch then
                    score.Crown.Visible = true
                end
            else
                place.Text = 2
                teamEntry.LayoutOrder = 1
            end
            place.Visible = true
        else
            place.Visible = false
        end
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

    for _: number, instance: Instance in ipairs(teamScoreFrame:GetChildren()) do
        if instance:IsA("Frame") and instance.Visible == true then
            instance:Destroy()
        end
    end
end

clearScoreboardEvent.OnClientEvent:Connect(ClearGui)

showScoreboardEvent.OnClientEvent:Connect(function(players: {[number]: table}, teamScores: {[string]: number})
    Open(players, teamScores, true)
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