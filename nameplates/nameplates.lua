-- local account = require('account')
-- local bit = require('bit')
local command = require('command')
local entities = require('entities')
-- local enumerable = require('enumerable')
-- local ffi = require('ffi')
local math = require('math')
local memory = require('memory')
local os = require('os')
-- local packet = require('packet')
-- local packets = require('packets')
-- local party = require('party')
local player = require('player')
-- local reflect = require('reflect')
-- local res = require('resources')
-- local scanner = require('scanner')
-- local set = require('sets')
-- local settings = require('settings')
-- local shared = require('shared')
-- local socket = require('socket')
local string = require('string')
-- local structs = require('structs')
-- local table = require('table')
local target = require('target')
local ui = require('ui')
-- local util = require('util')
local windower = require('windower')
-- local world = require('world')
-- local client = require('shared.client')

local screen = windower.settings.ui_size

local mm = function(m1, m2)
    local res = {}

    for i = 0, 3 do
        local row = {}
        for j = 0, 3 do
            local single = 0
            for k = 0, 3 do
                single = single + m1[i][k] * m2[k][j]
            end
            row[j] = single
        end
        res[i] = row
    end

    return res
end

local tov = function(entity)
    local pos = entity.position_display
    return {[0] = pos.x, pos.z, pos.y, pos.w}
end

local vm = function(v, m)
    local res = {}

    for i = 0, 3 do
        local single = 0
        for j = 0, 3 do
            single = single + v[j] * m[j][i]
        end
        res[i] = single
    end

    return res
end

local half_width = screen.width / 2
local half_height = screen.height / 2

local render_window = function(title, x_off, y_off)
    local width = 120
    ui.window('target_window', {
        title = title,
        x = (1 + x_off) * half_width - width / 2,
        y = (1 - y_off) * half_height,
        width = width,
        height = 0,
        style = 'chromeless',
    }, function() end)
end



local nameplate = function(entity, x_off, y_off)

    local width = 120
    local plate_state = {
        style = 'chromeless',
        x = (1 + x_off) * half_width - width / 2,
        y = ((1 - y_off) * half_height),
        color = ui.color.rgb(0,0,0,0),
        width = 200,
    }

    if plate_state.y > (screen.height - 200) then plate_state.y = screen.height - 200 end

    local current_target = target.t or nil

    ui.window('nameplate',plate_state, function()

        local hp_color = ui.color.rgb(128,255,128)

        if entity.hp_percent < 50 then hp_color = ui.color.rgb(255,255,128) end
        if entity.hp_percent < 25 then hp_color = ui.color.rgb(255,128,128) end

        if entity.target_type < 3 then
            ui.location(0,20)
            ui.size(120,5)
            ui.progress(entity.hp_percent/100, {color = hp_color})
        end

        if entity.id == player.id then
            local ls_color = entity.linkshell_color
            local ls_color_int = ui.color.tohex(ui.color.rgb(ls_color.red,ls_color.green,ls_color.blue))

            local mp_color = ui.color.rgb(128,128,255)
            local star_string = ''--player.superior_level
            if player.superior_level == 5 then star_string = '✨' end

            local tp_color = ui.color.gray
            local tp_percent = player.tp/1000 or 0
            if tp_percent > 1 then tp_color = ui.color.rgb(255,255,128) end
            if tp_percent > 2 then tp_color = ui.color.rgb(255,192,128) end
            if tp_percent == 3 then tp_color = ui.color.red end

            ui.location(90,15)
            ui.text(string.format('[%s]{%s}',player.hp,'Roboto bold italic 12px stroke:"10% #000000BB"'))
            ui.location(0,28)
            ui.size(120,5)
            ui.progress(player.mp_percent/100, {color = mp_color})
            ui.location(90,25)
            ui.text(string.format('[%s]{%s}',player.mp,'Roboto bold italic 12px stroke:"10% #000000BB"'))
            ui.location(0,36)
            ui.size(120,5)
            ui.progress(tp_percent,  {color = tp_color})
            ui.location(90,35)
            ui.text(string.format('[%s]{%s}',player.tp,'Roboto bold italic 12px stroke:"10% #000000BB"'))

            ui.location(0,45)
            ui.text(string.format(' [⬤]{%s}  [%s]{%s}[%s]{%s}','Roboto bold 12pt stroke:"10% #000000BB" '..ls_color_int,player.name,'Roboto color:white bold italic 12pt stroke:"10% #000000BB"',star_string,'Roboto color:white bold 10pt stroke:"10% #000000BB"'))
            if current_target then
                ui.location(20,65)
                ui.text(string.format('[ ⯈ %s]{%s}',current_target.name,'Roboto bold 9pt stroke:"10% #000000BB"'))
            end
        elseif entity.index == player.pet_index then
            local hp_string = ''
            if entity.hp_percent < 100 then hp_string = string.format(' (%s%%)',entity.hp_percent) end
            ui.location(5,30)
            ui.text(string.format('[%s%s]{%s}',entity.name,hp_string,'Roboto color:white bold italic 9pt stroke:"10% #000000BB"'))
        elseif current_target and entity.id == current_target.id then
            local hp_string = ''
            if entity.hp_percent < 100 then hp_string = string.format(' (%s%%)',entity.hp_percent) end
            local ls_color = entity.linkshell_color
            local ls_color_int = ui.color.tohex(ui.color.rgb(ls_color.red,ls_color.green,ls_color.blue))
            ui.location(5,30)
            if entity.target_type == 0 then 
                ui.text(string.format('[⬤]{%s}  [%s%s]{%s}','Roboto bold 9pt stroke:"10% #000000BB" '..ls_color_int,entity.name,hp_string,'Roboto color:white bold italic 9pt stroke:"10% #000000BB"'))
            else
                ui.text(string.format('[%s%s]{%s}',entity.name,hp_string,'Roboto color:white bold italic 9pt stroke:"10% #000000BB"'))
            end
        end
        
    end)

end

ui.display(function()
    local mat = mm(memory.graphics.view_matrix, memory.graphics.projection_matrix)

    for index = 0, 0x900 - 1 do
        local entity = entities[index]
        if entity and entity.display ~= nil and 
            (entity.id == player.id or 
            (target.t and entity.id == target.t.id) or
            (entity.index == entities[player.index].pet_index)
            ) then
            local res = vm(tov(entity), mat)
            if res[3] >= 0 then
                local x_off = res[0] / res[3]
                local y_off = res[1] / res[3]
                if x_off >= -half_width or x_off <= half_width or y_off >= -half_height or y_off <= half_height then
                    --render_window(string.format('%s', entity.name), x_off, y_off)
                    nameplate(entity, x_off, y_off)
                end
            end
        end
    end
end)