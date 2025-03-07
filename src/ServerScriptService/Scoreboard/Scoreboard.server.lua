local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local matchEvents: Folder = ServerScriptService.BindableEvents.Match
local matchStartedEvent: BindableEvent = matchEvents.MatchStartedEvent
local matchEndedEvent: BindableEvent = matchEvents.MatchEndedEvent
local getScoredboardFunction: RemoteFunction = ReplicatedStorage.RemoteFunctions.Gui.GetScoredboardFunction
local scoreboards: {[string]: table} = {}
local scoreboardLookup: {[string]: table} = {}

local function GetScoreboard(player: Player): ({[number]: table}, {[string]: {number}})
    local scoreboard = scoreboardLookup[player.UserId]
    if not scoreboard then return nil end

    return scoreboard["Players"], scoreboard["TeamScores"]
end

local function OnKill(killer: Player, victim: Player)

end

local function OnDeath(player: Player, gameName: string)
    scoreboards[gameName]["Players"][player.UserId]["Deaths"] += 1

    for teamName: string, _: number in pairs(scoreboards[gameName]["TeamScores"]) do
        if teamName ~= player.Team.Name then
            scoreboards[gameName]["TeamScores"][teamName] += 1
        end
    end
end

local function OnMatchStarted(player: Player, gameFolder: Folder)
    local gameName: string = gameFolder.Name

    if not scoreboards[gameName] then
        scoreboards[gameName] =
        {
            ["Players"] = {},
            ["TeamScores"] = {},
            ["Connections"] = {}
        }
    end

    if not scoreboards[gameName]["TeamScores"][player.Team.Name] then
        scoreboards[gameName]["TeamScores"][player.Team.Name] = 0
    end

    scoreboards[gameName]["Players"][player.UserId] =
    {
        ["DisplayName"] = player.DisplayName,
        ["CharacterAppearanceId"] = player.CharacterAppearanceId,
        ["Team"] = player.Team.Name,
        ["Color"] = player.Team.TeamColor.Color,
        ["Kills"] = 0,
        ["Deaths"] = 0
    }

    table.insert(scoreboards[gameName]["Connections"], player.CharacterRemoving:Connect(function()
        OnDeath(player, gameName)
    end))

    scoreboardLookup[player.UserId] = scoreboards[gameName]
end

local function OnMatchEnded(player: Player, gameFolder: Folder)
    local gameName: string = gameFolder.Name
    local showScoreboardEvent: RemoteEvent = ReplicatedStorage.Events.Gui.ShowScoreboardEvent

    showScoreboardEvent:FireClient(player, GetScoreboard(player))
    scoreboardLookup[player.UserId] = nil

    if scoreboards[gameName] then
        for _: number, connection: RBXScriptConnection in ipairs(scoreboards[gameName]["Connections"]) do
            connection:Disconnect()
        end

        scoreboards[gameName] = nil
    end
end

matchStartedEvent.Event:Connect(OnMatchStarted)
matchEndedEvent.Event:Connect(OnMatchEnded)

getScoredboardFunction.OnServerInvoke = (function(player: Player)
    return GetScoreboard(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
    scoreboardLookup[player.UserId] = nil
end)