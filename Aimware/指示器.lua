local function require(name, url)
    package = package or {}

    package.loaded = package.loaded or {}

    package.loaded[name] =
        package.loaded[name] or RunScript(name .. ".lua") or
        http.Get(
            url,
            function(body)
                file.Write(name .. ".lua", body)
            end
        )

    return package.loaded[name] or error("unable to load module " .. name .. " ( try to reload )", 2)
end

local function menu_weapon(var)
    local w = var:match("%a+"):lower()
    local w = w:find("heavy") and "hpistol" or w:find("auto") and "asniper" or w:find("submachine") and "smg" or w:find("light") and "lmg" or w
    return w
end

local ui = {}
ui.ref = gui.Reference("visuals", "other", "extra")
ui.multi_box = gui.Multibox(ui.ref, "ðæç¤ºå¨")
ui.multi_box:SetDescription("å¨å·¦ä¾§æ¾ç¤ºæç¤ºå¨")

ui.option = {
    gui.Checkbox(ui.multi_box, "indicators.ct", "æç¤ºå¨ææ¬", 1),
    gui.Checkbox(ui.multi_box, "indicators.lr", "åæ³/ æ´å", 1),
    gui.Checkbox(ui.multi_box, "indicators.af", "èªå¨å¼ç«", 1),
    gui.Checkbox(ui.multi_box, "indicators.fov", "èªçèå´", 1),
    gui.Checkbox(ui.multi_box, "indicators.hc", "æå°å½ä¸­ç", 1),
    gui.Checkbox(ui.multi_box, "indicators.dmg", "æå°ä¼¤å®³", 1),
    gui.Checkbox(ui.multi_box, "indicators.aw", "èªå¨ç©¿å¢", 1),
    gui.Checkbox(ui.multi_box, "indicators.fl", "åå¡", 1),
    gui.Checkbox(ui.multi_box, "indicators.fd", "åè¹²", 1),
    gui.Checkbox(ui.multi_box, "indicators.dt", "DT", 1),
    gui.Checkbox(ui.multi_box, "indicators.lc", "æ»åè¡¥å¿", 1)
}

ui.edit_box = gui.Editbox(ui.ref, "indicators.custom.text", "ðæç¤ºå¨ææ¬")
ui.edit_box:SetDescription("èªå®ä¹æç¤ºå¨ææ¬")
ui.edit_box:SetValue("ðAimware")
ui.edit_box:SetHeight(45)
ui.option.clr = {}
for i = 1, #ui.option do
    ui.option.clr[i] = gui.ColorPicker(ui.option[i], "clr", "clr", 255, 255, 255, 255)
end

local origin_records = {}
local globals_CurTime, globals_TickInterval = globals.CurTime, globals.TickInterval
local math_floor = math.floor

local function time_to_ticks(a)
    return math_floor(1 + a / globals_TickInterval())
end

local function on_create_move(cmd)
    local lp = entities.GetLocalPlayer()
    if not (lp and lp:IsAlive()) then
        return
    end
    if ui.option[11]:GetValue() then
        if cmd.sendpacket then
            origin_records[#origin_records + 1] = lp:GetAbsOrigin()
        end
    end
end

local function on_draw()
    local lp = entities.GetLocalPlayer()

    if not (lp and lp:IsAlive()) then
        return
    end

    local lbot = gui.GetValue("lbot.master")
    local rbot = gui.GetValue("rbot.master")

    if ui.option[11]:GetValue() and origin_records[1] and origin_records[2] then
        local r, g, b, a = ui.option.clr[11]:GetValue()
        local delta =
            Vector3(origin_records[2].x - origin_records[1].x, origin_records[2].y - origin_records[1].y, origin_records[2].z - origin_records[1].z)
        if delta:Length2D() ^ 2 > 4096 then
            draw.indicator(r, g, b, a, "ðLC")
        end
        if origin_records[3] then
            table.remove(origin_records, 1)
        end
    end

    if ui.option[10]:GetValue() then
        local weapon = menu_weapon(gui.GetValue("rbot.accuracy.weapon"))
        local dt_pcall = pcall(gui.GetValue, "rbot.accuracy.weapon." .. weapon .. ".doublefire")

        if dt_pcall and gui.GetValue("rbot.accuracy.weapon." .. weapon .. ".doublefire") > 1 then
            local m_flNextSecondaryAttack = lp:GetPropEntity("m_hActiveWeapon"):GetPropFloat("LocalActiveWeaponData", "m_flNextSecondaryAttack")
            local r, g, b, a = ui.option.clr[10]:GetValue()
            if m_flNextSecondaryAttack > globals_CurTime() + 0.03 then
                r, g, b, a = 255, 0, 0, 255
            end
            draw.indicator(r, g, b, a, "ðDT")
        end
    end

    if ui.option[9]:GetValue() then
        local fakecrouchkey = gui.GetValue("rbot.antiaim.extra.fakecrouchkey")
        if fakecrouchkey ~= 0 and input.IsButtonDown(fakecrouchkey) then
            local r, g, b, a = ui.option.clr[9]:GetValue()
            draw.indicator(r, g, b, a, "ðFD")
        end
    end

    if ui.option[8]:GetValue() then
        local r, g, b, a = ui.option.clr[8]:GetValue()

        local fl = time_to_ticks(globals_CurTime() - lp:GetPropFloat("m_flSimulationTime")) + 2
        draw.indicator(r, g, b, a, "ðFL " .. fl)
    end

    if ui.option[7]:GetValue() and gui.GetValue("rbot.hitscan.mode." .. menu_weapon(gui.GetValue("rbot.hitscan.mode")) .. ".autowall") then
        local r, g, b, a = ui.option.clr[7]:GetValue()
        draw.indicator(r, g, b, a, "ðAW")
    end

    if ui.option[6]:GetValue() then
        local r, g, b, a = ui.option.clr[6]:GetValue()
        local weapon = menu_weapon(gui.GetValue("rbot.accuracy.weapon"))
        local text = gui.GetValue("rbot.accuracy.weapon." .. weapon .. ".mindmg")
        draw.indicator(r, g, b, a, "ðDMG: " .. ((text > 100) and ("HP+" .. (text - 100)) or text))
    end

    if ui.option[5]:GetValue() then
        local r, g, b, a = ui.option.clr[5]:GetValue()
        local weapon = menu_weapon(gui.GetValue("rbot.accuracy.weapon"))
        local text = gui.GetValue("rbot.accuracy.weapon." .. weapon .. ".hitchance")
        draw.indicator(r, g, b, a, "ðHC: " .. text)
    end

    if ui.option[4]:GetValue() then
        local r, g, b, a = ui.option.clr[4]:GetValue()
        local weapon = menu_weapon(gui.GetValue("lbot.weapon.target"))
        local text =
            lbot and ("ð%.1f"):format(gui.GetValue("lbot.weapon.target." .. weapon .. ".maxfov")) or rbot and gui.GetValue("rbot.aim.target.fov")
        draw.indicator(r, g, b, a, text .. "Â°")
    end

    if ui.option[3]:GetValue() and ((lbot and gui.GetValue("lbot.aim.autofire")) or (rbot and gui.GetValue("rbot.aim.enable"))) then
        local r, g, b, a = ui.option.clr[3]:GetValue()
        draw.indicator(r, g, b, a, "ðAF")
    end

    if ui.option[2]:GetValue() then
        local r, g, b, a = ui.option.clr[2]:GetValue()
        local text = lbot and "ðLegit" or rbot and "ðRage"
        draw.indicator(r, g, b, a, text)
    end

    ui.edit_box:SetInvisible(not ui.option[1]:GetValue())
    if ui.option[1]:GetValue() then
        local r, g, b, a = ui.option.clr[1]:GetValue()
        local text = ui.edit_box:GetValue()
        draw.indicator(r, g, b, a, text)
    end
end

callbacks.Register("CreateMove", on_create_move)
callbacks.Register("Draw", on_draw)