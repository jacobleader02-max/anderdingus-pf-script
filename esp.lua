local ESP   = {}
local store = {}
local CFG, C, newDraw, getAll

function ESP.init(cfg, utils, playersMod)
    CFG     = cfg
    C       = utils.C
    newDraw = utils.newDraw
    getAll  = playersMod.getAll
end

local function get(model)
    if store[model] then return store[model] end
    local e = {
        outline = newDraw("Square",{Thickness=2,Color=C.black, Filled=false,Visible=false}),
        box     = newDraw("Square",{Thickness=1,Color=C.accent,Filled=false,Visible=false}),
        name    = newDraw("Text",  {Size=13,Color=C.text,   Center=true,Outline=true,Visible=false,Text=""}),
        dist    = newDraw("Text",  {Size=11,Color=C.textDim,Center=true,Outline=true,Visible=false,Text=""}),
        health  = newDraw("Text",  {Size=11,Color=C.green,  Center=true,Outline=true,Visible=false,Text=""}),
    }
    store[model] = e
    return e
end

local function hide(e)
    for _,obj in pairs(e) do if obj then pcall(function() obj.Visible=false end) end end
end

function ESP.update(players, camera, myPos)
    local active = {}
    for _, data in ipairs(players) do
        active[data.model] = true
        local e = get(data.model)
        if not CFG.ESPEnabled or (CFG.ESPTeamCheck and data.isMyTeam) then
            hide(e) continue
        end

        local headPos = data.aimPart.Position  + Vector3.new(0, data.aimPart.Size.Y/2  + 0.3, 0)
        local feetPos = data.feetPart.Position - Vector3.new(0, data.feetPart.Size.Y/2, 0)
        local tv, on  = camera:WorldToViewportPoint(headPos)
        local bv      = camera:WorldToViewportPoint(feetPos)
        if not on or tv.Z < 0 then hide(e) continue end

        local dist = myPos and (data.aimPart.Position - myPos).Magnitude or 0
        if dist > 2000 then hide(e) continue end

        local bh = math.abs(bv.Y - tv.Y)
        local bw = bh * 0.5
        local bx = tv.X - bw/2
        local by = tv.Y

        if e.outline then e.outline.Size=Vector2.new(bw+2,bh+2) e.outline.Position=Vector2.new(bx-1,by-1) e.outline.Visible=CFG.ShowBoxes end
        if e.box     then e.box.Size=Vector2.new(bw,bh) e.box.Position=Vector2.new(bx,by) e.box.Visible=CFG.ShowBoxes end
        if e.name    then e.name.Text=data.name e.name.Position=Vector2.new(tv.X,by-15) e.name.Visible=CFG.ShowNames end
        if e.dist    then e.dist.Text=string.format("%.0fm",dist*0.28) e.dist.Position=Vector2.new(tv.X,by+bh+2) e.dist.Visible=CFG.ShowDistance end
        if e.health  then e.health.Text=string.format("♥ %.0f%%",data.healthPct) e.health.Position=Vector2.new(bx-4,by+bh/2-5) e.health.Visible=CFG.ShowHealth end
    end

    for model,e in pairs(store) do
        if not active[model] then
            for _,obj in pairs(e) do if obj then pcall(function() obj:Remove() end) end end
            store[model] = nil
        end
    end
end

return ESP
