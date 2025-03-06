local ServerScriptService = game:GetService("ServerScriptService")
local matchEvents: Folder = ServerScriptService.BindableEvents.Match
local matchStartedEvent: BindableEvent = matchEvents.MatchStartedEvent
local matchEndedEvent: BindableEvent = matchEvents.MatchEndedEvent
local scoreboards: {} = {}

local function OnKill(killer: Player, victim: Player)

end

local function OnDeath(player: Player, gameName: string)
    scoreboards[gameName]["Players"][player.UserId]["Deaths"] += 1

    for team: Team, _: number in pairs(scoreboards[gameName]["Score"]) do
        if team ~= player.Team then
            scoreboards[gameName]["Score"][team] += 1
            print(string.format("%s: %i", team.Name, scoreboards[gameName]["Score"][team]))
        end
    end
end

local function OnMatchStarted(player: Player, gameFolder: Folder)
    local gameName: string = gameFolder.Name

    if not scoreboards[gameName] then
        scoreboards[gameName] =
        {
            ["Players"] = {},
            ["Score"] = {},
            ["Connections"] = {}
        }
    end

    if not scoreboards[gameName]["Score"][player.Team] then
        scoreboards[gameName]["Score"][player.Team] = 0
    end

    scoreboards[gameName]["Players"][player.UserId] =
    {
        ["Kills"] = 0,
        ["Deaths"] = 0
    }

    table.insert(scoreboards[gameName]["Connections"], player.CharacterRemoving:Connect(function()
        OnDeath(player, gameName)
    end))
end

local function OnMatchEnded(_: Player, gameFolder: Folder)
    local gameName: string = gameFolder.Name

    if scoreboards[gameName] then
        for _: number, connection: RBXScriptConnection in ipairs(scoreboards[gameName]["Connections"]) do
            connection:Disconnect()
        end

        scoreboards[gameName] = nil
    end
end

matchStartedEvent.Event:Connect(OnMatchStarted)
matchEndedEvent.Event:Connect(OnMatchEnded)