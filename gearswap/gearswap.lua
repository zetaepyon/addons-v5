local action = require('action')
local chat = require('chat')
local command = require('command')
local entities = require('entities')
local items = require('items')
local packets = require('packets')
local player = require('player')
local res = require('resources')
local string = require('string')
local table = require('table')
local ui = require('ui')
local windower = require('windower')

local statics = require('statics')
local debug = require('utility')
local current_action = {name = 'None'}

-- Enrich and return action target provided by packet
local enhance_target = function(packet)

    local target_entity = entities[packet.target_index] or nil
    if not target_entity then
        return
    end

    local target_vars = {'name', 'id', 'index', 'distance', 'hp_percent', 'status', 'claim_id', 'race_id', 'movement_speed', 'movement_speed_base', 'model_size', 'heading', 'spawn_type', 'target_type'}
    local target = {}
    for _,var in pairs(target_vars) do
        if target_entity[var] then
            target[var] = target_entity[var]
        end
    end

    if target.id == player.id then
        target.mp_percent = player.mp_percent
        target.tp = player.tp
    end

    if target.target_type then
        target.type = target.target_type
        target.target_type = nil
    end

    if target.status then
        target.status = res.statuses[target.status].en
    end

    if target.race_id then
        target.race = res.races[target.race_id].en
    end

    if target_entity.position then
        target.x = target_entity.position.x
        target.y = target_entity.position.y
        target.z = target_entity.position.z
    end

    return target

end

-- Parse an action packet and return an enriched table
local parse_action = function(packet)

    local act = {}
    act.category = packet.action_category
    act.name = "Unknown"

    local category_name = statics.category_names[act.category]
    local resource_table
    if act.category == 0x10 then
        resource_table = {id="0", index="0", prefix="/range", english="Ranged", japanese="飛び道具", type="Misc", element="None", targets={"Enemy"}}
    else
        resource_table = res[category_name][packet.param]
    end
    local action_vars = {'name', 'prefix', 'targets', 'type', 'skill', 'mp_cost', 'tp_cost', 'element', 'range', 'recast', 'recast_id', 'cast_time'}

    for _,v in pairs(action_vars) do
        if resource_table[v] then
            act[v] = resource_table[v]
        end
    end

    local skillchain_props = {'skillchain_a', 'skillchain_b', 'skillchain_c'}
    for k,v in pairs(skillchain_props) do
        if act.category == 7 and resource_table[v] ~= '' then
            if not act.skillchain then
                act.skillchain = {}
            end
            act.skillchain[k] = resource_table[v]
        end
    end

    act.target = enhance_target(packet)

    return act

end

-- Return list of inventory matches based on item name
local match_item = function(item_name)

    local equippable = statics.equippable_bags
    local normalized = string.lower(item_name)
    local matches = {}

    for _,bag in pairs(equippable) do
        for i = 1,80 do
            local item = items.bags[bag][i].item or nil
            if item and (normalized == string.lower(item.en) or normalized == string.lower(item.enl)) then
                table.insert(matches, {id = item.id, bag_id = bag, bag_index = i})
            end
        end
    end

    return matches

end

-- Return the valid slots for an item (by id)
local valid_slots = function(item_id)
    local slot_map = statics.slot_map
    return slot_map[res.items[item_id].slots]
end

-- Enhance matches
local refine_matches = function(matches)

    local refined_match = {}

    for _,item in ipairs(matches) do
        if item then
            -- TO DO: enhance with intelligent slot selection logic instead of just picking first
            local valid_slot = valid_slots(item.id)[1]
            debug.message('Equipping Item: ' .. res.items[item.id].enl .. ' (' .. item.id .. ') in bag ' .. item.bag_id .. ' index ' .. item.bag_index .. ' to slot ' .. valid_slot)
            refined_match = {bag_index = item.bag_index, slot_id = valid_slot, bag_id = item.bag_id}
        else
            debug.message('Item not found')
        end
    end

    return refined_match

end

-- Parse a table of equipment and return items
local parse_set = function(item_set)

    local items = {}

    for _,item_name in pairs(item_set) do
        local matches = match_item(item_name)
        local refined_match = refine_matches(matches)
        table.insert(items, refined_match)
    end

    return items

end

-- Inject packet for the assembled equipset
local inject_equipset_packet = function(items)
    packets.outgoing[0x051]:inject({
        count = #items,
        equipment = items,
    })
end

local equip = function(set)
    local items = parse_set(set)
    inject_equipset_packet(items)
end

local user_env = {
    require = require,
    chat = chat,
    string = string,
    lua_base_path = windower.package_path,
    debug = debug,
    equip = equip,
}

local load_userscript = function(filename)

    local funct, err = loadfile(windower.package_path .. '\\' .. 'data' .. '\\' .. filename .. '.lua')
    if funct == nil then
        debug.message('User File problem', err)
        return
    else
        debug.message('Loading user script', filename)
    end

    setfenv(funct, user_env)

    local status, name = pcall(funct)
    if not status then
        debug.message('Failed to load', name)
        return nil
    end

end

local user_pcall = function(str,...)
    if type(user_env[str]) == 'function' then
        local bool, err = pcall(user_env[str], ...)
        if not bool then
            debug.message('Error in user function', str .. ' - ' .. err)
        end
    elseif user_env[str] then
        debug.message('Not a function', str)
    end
end

ui.display(function()
    if not debug.window.closed then
        debug.window, debug.window.closed = ui.window('gearswap', debug.window, function()
            ui.text(debug.stringify(current_action))
        end)
    end
end)

action.filter_action:register(function(packet)
    -- action.block()
    local act = parse_action(packet)
    current_action = act
    user_pcall('filter_action', act)
end)

action.pre_action:register(function()
    user_pcall('pre_action', current_action)
end)

action.mid_action:register(function()
    user_pcall('mid_action', current_action)
end)

action.post_action:register(function()
    user_pcall('post_action', current_action)
end)

local gs_command = command.new('gs')

gs_command:register('help', function()
    chat.add_text('GearSwap Help')
end)

gs_command:register('load', load_userscript, '<file_name:text>')
gs_command:register('l', load_userscript, '<file_name:text>')

gs_command:register('actionui', function()
    debug.window.closed = not debug.window.closed
end)

gs_command:register('equipitem', function(item_name)
    local matches = match_item(item_name)
    local item = {refine_matches(matches)}
    inject_equipset_packet(item)
end, '<item_name:text>')

--[[
Copyright © 2019, Windower Dev Team
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Windower Dev Team nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE WINDOWER DEV TEAM BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
