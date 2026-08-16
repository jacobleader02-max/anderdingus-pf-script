local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local WP          = workspace:WaitForChild("Players", 10)

local M = {}

function M.getAll()
    local result   = {}
    if not WP then return result end
    local myColor  = LocalPlayer.TeamColor

    for _, folder in ipairs(WP:GetChildren()) do
        for _, model in ipairs(folder:GetChildren()) do
            local gui = model:FindFirstChild("NameTagGui", true)
            if not gui then continue end
            local tag = gui:FindFirstChild("PlayerTag")
            if not tag or tag.Text == "" then continue end
            local name = tag.Text

            local plr      = Players:FindFirstChild(name)
            local isMyTeam = plr ~= nil and plr.TeamColor == myColor

            local healthPct = 100
            local hFrame    = gui:FindFirstChild("Health")
            if hFrame then
                local pct = hFrame:FindFirstChild("Percent")
                if pct then
                    healthPct = math.clamp((pct.Size.X.Offset / 80) * 100, 0, 100)
                end
            end
            if healthPct <= 0 then continue end

            local highestY = -math.huge
            local lowestY  =  math.huge
            local aimPart  = nil
            local feetPart = nil

            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and v.Size.Magnitude > 0.5 then
                    if v.Position.Y > highestY then
                        highestY = v.Position.Y
                        aimPart  = v
                    end
                    if v.Position.Y < lowestY then
                        lowestY  = v.Position.Y
                        feetPart = v
                    end
                end
            end

            if not aimPart then continue end

            table.insert(result, {
                name      = name,
                model     = model,
                isMyTeam  = isMyTeam,
                aimPart   = aimPart,
                feetPart  = feetPart or aimPart,
                healthPct = healthPct,
            })
        end
    end
    return result
end

return M
