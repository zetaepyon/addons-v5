local windower = require('core.windower')
local ui = require('core.ui')
local command = require('core.command')
local settings = require('settings')
local equipment = require('equipment')

local default = {
    pos = {
        x = 1000,
        y = 450,
    }
}
local options = settings.load(default)

local size = 2
local state = {
    title = 'EquipViewer',
    style = 'chromeless',
    color = ui.color.rgb(0,0,0,128),
    width = 69 * size,
    height = 69 * size,
    x = options.pos.x,
    y = options.pos.y,
    resizable = false,
    moveable = true,
    closable = false,
}
local slot_map = {0,1,2,3,4,9,11,12,5,6,13,14,15,10,7,8}

ui.display(function()
    state = ui.window('ev', state, function()
        local x, y = size, size
        for pos, slot in ipairs(slot_map) do
            ui.location(x, y)
            ui.size(32,32)
            ui.image(windower.package_path..'\\icons\\'..'32'..'\\'..equipment[slot].item.id..'.png')
            x = x + 17 * size
            if pos % 4 == 0 then
                x = size
                y = y + 17 * size
            end
        end
    end)
end)

local ev = command.new('ev')
ev:register('layout', function()
    state.style = (state.style == 'chromeless') and 'layout' or 'chromeless'

    if state.style == 'chromeless' then
        -- save it
        options.pos.x = state.x
        options.pos.y = state.y
        settings.save()
    end
end)