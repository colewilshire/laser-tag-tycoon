local Players = game:GetService("Players")
local scripts: Folder = script.Parent
local teleporter: Part = scripts.Parent
local primaryPart: Part = teleporter.PrimaryPart
local exit: Part = teleporter.Exit
local playersInLobby: {[string]: boolean} = {}
local maxPlayers: number = teleporter:GetAttribute("MaxPlayers") or 10
local currentPlayers: number = 0
local timerLength: number = teleporter:GetAttribute("TimerLength") or 60
local timerGui: BillboardGui = teleporter.TimerGui
local timerText: TextLabel = timerGui.TimerText
local playerCountText: TextLabel = timerGui.PlayerCountText
local timerThread: thread

local function FormatTime(timeRemaining: number)
    local minutes: number = math.floor(timeRemaining / 60)
    local seconds: number = timeRemaining % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function AddPlayerToLobby(player: Player)
    playersInLobby[player] = true
    currentPlayers += 1
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
end

local function RemovePlayerFromLobby(player: Player)
    playersInLobby[player] = nil
    currentPlayers -= 1
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
end

local function CancelTimer()
    coroutine.close(timerThread)
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
    timerText.Text = "(Need at least two people to start)"
    timerThread = nil
end

local function OnTimerEnd()
    for player: Player, _: boolean in pairs(playersInLobby) do
        print(player.Name)
    end

    playersInLobby = {}
    currentPlayers = 0
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
    timerText.Text = "(Need at least two people to start)"
    timerThread = nil
end

local function StartTimer()
    for i: number = timerLength, 0, -1 do
        timerText.Text = FormatTime(i)
        task.wait(1)
    end

    OnTimerEnd()
end

local function OnTouch(otherPart: BasePart)
    local character: Model? = otherPart.Parent
    local player: Player? = Players:GetPlayerFromCharacter(character)

    if not player or currentPlayers >= maxPlayers or playersInLobby[player] then
        return
    end

    local lastPlayer: Player? = next(playersInLobby)
    local secondToLastPlayer: Player? = lastPlayer and next(playersInLobby, lastPlayer)

    if lastPlayer and secondToLastPlayer == nil then
        timerThread = coroutine.create(StartTimer)

        coroutine.resume(timerThread)
    end

    AddPlayerToLobby(player)
end

local function OnExit(otherPart: BasePart)
    local character: Model? = otherPart.Parent
    local player: Player? = Players:GetPlayerFromCharacter(character)

    if not (player and playersInLobby[player]) then
        return
    end

    RemovePlayerFromLobby(player)

    local lastPlayer: Player? = next(playersInLobby)
    local secondToLastPlayer: Player? = lastPlayer and next(playersInLobby, lastPlayer)

    if secondToLastPlayer == nil and timerThread then
        CancelTimer()
    end
end

primaryPart.Touched:Connect(function(otherPart: BasePart)
    OnTouch(otherPart)
end)

exit.Touched:Connect(function(otherPart: BasePart)
    OnExit(otherPart)
end)

Players.PlayerRemoving:Connect(function(player: Player)
    if playersInLobby[player] then
        RemovePlayerFromLobby(player)
    end
end)

playerCountText.Text = currentPlayers .. " / " .. maxPlayers