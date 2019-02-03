local os = require('os')
local math = require('math')
local table = require('table')
local string = require('string')
local ui = require('ui')
local list = require('lists')
local settings = require('settings')

local time_zones = require('time_zones')
local local_offset = os.date('%z')/100

defaults = {}
defaults.pos = {}
defaults.pos.x = 1555
defaults.pos.y = 23
defaults.format = '%H:%M'
defaults.style = '12pt color:#FFFFFFDD Roboto bold condensed stroke:"6% #000000AA"'
defaults.showtimezones = true
defaults.separator = ' | '
defaults.sort = 'Time'
defaults.timezones = {'CST','PST','JST',}

options = settings.load(defaults)

local sort = {    
    time = function(t1, t2)
        return time_zones[t1] < time_zones[t2]
    end,
    alphabetical = function(t1, t2)
        return t1 < t2
    end,
}

options.timezones = options.sort ~= 'None' and table.sort(options.timezones,sort[options.sort:lower()]) or options.timezones

ui.display(function()

    local clock = {'['}
    
    for i,v in ipairs(options.timezones) do

        local tz_name = ' '..v
        local tz_offset = time_zones[v]
        local tz_time = os.date(options.format, os.time() + ((tz_offset - local_offset) * 3600))
        
        if i ~= 1 then table.insert(clock, options.separator) end
        table.insert(clock, tz_time)
        if options.showtimezones then table.insert(clock, tz_name) end

    end

    table.insert(clock, ']{')
    table.insert(clock, options.style)
    table.insert(clock, '}')

    ui.location(options.pos.x, options.pos.y)
    ui.text(table.concat(clock))

end)