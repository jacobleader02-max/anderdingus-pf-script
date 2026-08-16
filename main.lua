local BASE = "https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/"

local function req(file)
    return loadstring(game:HttpGet(BASE..file))()
end

local Utils   = req("utils.lua")
local CFG     = req("config.lua")
local Players = req("players.lua")
local ESP     = req("esp.lua")
local Aimbot  = req("aimbot.lua")
local UI      = req("ui.lua")

ESP.init(CFG, Utils, Players)
Aimbot.init(CFG)
UI.init(CFG, Utils)

local Camera      = workspace.CurrentCamera
local RunService  = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible   = false
FOVCircle.Radius    = CFG.FOV
FOVCircle.Color     = Color3.fromRGB(140,70,255)
FOVCircle.Thickness = 1
FOVCircle.Filled    = false
FOVCircle.NumSides  = 64

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
    FOVCircle.Radius   = CFG.FOV
    FOVCircle.Visible  = CFG.AimbotEnabled

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos  = myRoot and myRoot.Position

    local players = Players.getAll()

    if CFG.AimbotEnabled and Aimbot.isHeld() then
        local target = Aimbot.getTarget(players, Camera)
        Aimbot.apply(target, Camera)
    end

    ESP.update(players, Camera, myPos)
end)
