local UserInputService = game:GetService("UserInputService")

local Aimbot = {}
local CFG

function Aimbot.init(cfg)
    CFG = cfg
end

function Aimbot.isHeld()
    if CFG.AimKeyType == "mouse" then
        return UserInputService:IsMouseButtonPressed(CFG.AimKeyMouse)
    else
        return CFG.AimKeyCode ~= nil and UserInputService:IsKeyDown(CFG.AimKeyCode) or false
    end
end

function Aimbot.getTarget(players, camera)
    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local best   = CFG.FOV
    local bestPart = nil

    for _, data in ipairs(players) do
        if CFG.AimTeamCheck and data.isMyTeam then continue end
        local sp, on = camera:WorldToViewportPoint(data.aimPart.Position)
        if not on or sp.Z < 0 then continue end
        local d = (Vector2.new(sp.X,sp.Y) - center).Magnitude
        if d < best then
            best     = d
            bestPart = data.aimPart
        end
    end
    return bestPart
end

function Aimbot.apply(target, camera)
    if not target then return end
    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local sp     = camera:WorldToViewportPoint(target.Position)
    local delta  = Vector2.new(sp.X,sp.Y) - center
    local s      = math.clamp(1 - (CFG.Smoothness/100), 0.01, 1)
    pcall(function()
        mousemoverel(delta.X * s, delta.Y * s)
    end)
end

function Aimbot.removeRecoil()
    if not CFG.RecoilEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    pcall(function()
        mousemoverel(0, CFG.RecoilStrength)
    end)
end

return Aimbot
