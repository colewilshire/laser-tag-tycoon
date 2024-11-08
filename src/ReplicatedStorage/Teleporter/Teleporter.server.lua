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

local function formatTime(timeRemaining: number)
    local minutes: number = math.floor(timeRemaining / 60)
    local seconds: number = timeRemaining % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function OnTimerEnd()
    for player: Player, _: boolean in pairs(playersInLobby) do
        print(player.Name)
    end

    playersInLobby = {}
    currentPlayers = 0
    timerText.Visible = false
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
    timerThread = nil
end

local function StartTimer()
    for i: number = timerLength, 0, -1 do
        timerText.Text = formatTime(i)
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

    if next(playersInLobby) == nil then
        timerText.Visible = true
        timerThread = coroutine.create(StartTimer)

        coroutine.resume(timerThread)
    end

    playersInLobby[player] = true
    currentPlayers += 1
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers
end

local function OnExit(otherPart: BasePart)
    local character: Model? = otherPart.Parent
    local player: Player? = Players:GetPlayerFromCharacter(character)

    if not (player and playersInLobby[player]) then
        return
    end

    playersInLobby[player] = nil
    currentPlayers -= 1
    playerCountText.Text = currentPlayers .. " / " .. maxPlayers

    if next(playersInLobby) == nil and timerThread then
        coroutine.close(timerThread)
        OnTimerEnd()
    end
end

primaryPart.Touched:Connect(function(otherPart: BasePart)
    OnTouch(otherPart)
end)

exit.Touched:Connect(function(otherPart: BasePart)
    OnExit(otherPart)
end)

playerCountText.Text = currentPlayers .. " / " .. maxPlayers