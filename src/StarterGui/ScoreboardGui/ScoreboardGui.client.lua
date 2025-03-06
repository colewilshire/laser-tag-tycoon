local Players = game:GetService("Players")
local gui: ScreenGui = script.Parent.Parent
local guiFrame: Frame = gui.GuiFrame
local team1Frame: Frame = guiFrame.Team1Frame
local team2Frame: Frame = guiFrame.Team2Frame
local testPlayerList: {} =
{
    ["Team1"] = {
        [31571502] =
        {
            ["DisplayName"] = "REDxHOSS88",
            ["Kills"] = 33,
            ["Deaths"] = 27
        }
    },
    ["Team2"] = {
        [31571502] =
        {
            ["DisplayName"] = "The_Other_Guy",
            ["Kills"] = 22,
            ["Deaths"] = 55
        }
    },
}

local function ClearGui()
    for _: number, frame: Frame in ipairs(team1Frame:GetChildren()) do
        frame:Destroy()
    end
end

local function InitializeGui(scoreboard: table)
    -- for teamName: string, playerList: table in pairs(scoreboard) do
    --     for userId: number, playerStats: table in pairs(playerList) do
    --         local templateFrameClone: Frame = team1Frame.TemplateFrame:Clone()
    --         local portrait: ImageLabel = templateFrameClone.Portrait
    --         local displayName: TextLabel = templateFrameClone.DisplayName
    --         local kills: TextLabel = templateFrameClone.Kills
    --         local deaths: TextLabel = templateFrameClone.Deaths

    --         portrait.Image = Players:GetUserThumbnailAsync(userId, 0, 0)
    --         displayName.Text = playerStats["DisplayName"]
    --         kills.Text = playerStats["Kills"]
    --         deaths.Text = playerStats["Deaths"]
    --         templateFrameClone.Name = "TestTestTest"
    --         templateFrameClone.Parent = team1Frame
    --         templateFrameClone.Visible = true
    --     end
    -- end

    for userId: number, playerStats: table in pairs(scoreboard["Team1"]) do
        local templateFrameClone: Frame = team1Frame.TemplateFrame:Clone()
        local portrait: ImageLabel = templateFrameClone.Portrait
        local displayName: TextLabel = templateFrameClone.DisplayName
        local kills: TextLabel = templateFrameClone.Kills
        local deaths: TextLabel = templateFrameClone.Deaths

        portrait.Image = Players:GetUserThumbnailAsync(userId, 0, 0)
        displayName.Text = playerStats["DisplayName"]
        kills.Text = playerStats["Kills"]
        deaths.Text = playerStats["Deaths"]
        templateFrameClone.Name = "TestTestTest"
        templateFrameClone.Parent = team1Frame
        templateFrameClone.Visible = true
    end

    for userId: number, playerStats: table in pairs(scoreboard["Team2"]) do
        local templateFrameClone: Frame = team2Frame.TemplateFrame:Clone()
        local portrait: ImageLabel = templateFrameClone.Portrait
        local displayName: TextLabel = templateFrameClone.DisplayName
        local kills: TextLabel = templateFrameClone.Kills
        local deaths: TextLabel = templateFrameClone.Deaths

        portrait.Image = Players:GetUserThumbnailAsync(userId, 0, 0)
        displayName.Text = playerStats["DisplayName"]
        kills.Text = playerStats["Kills"]
        deaths.Text = playerStats["Deaths"]
        templateFrameClone.Name = "TestTestTest"
        templateFrameClone.Parent = team2Frame
        templateFrameClone.Visible = true
    end
end

InitializeGui(testPlayerList)