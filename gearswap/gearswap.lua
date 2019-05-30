local action = require('action')
local res = require('resources')
local chat = require('chat')
local entities = require('entities')
local player = require('player')
local string = require('string')
local windower = require('windower')
local command = require('command')
local items = require('items')
local table = require('table')
local packets = require('packets')

local statics = require('statics')
local util = require('utility')
stringify = util.stringify
debug_msg = util.debug_msg

local debug = {
    info = false,
    error = false,
    swaps = false,
}

current_action = {}
require('actionui')

-- Enrich and return action target provided by packet
local function enhance_target(packet)

    local target_entity = entities[packet.target_index] or nil

    if packet.target_index and target_entity then

        local target_vars = {'name','id','index','distance','hp_percent','status','claim_id','race_id','movement_speed','movement_speed_base','model_size','heading','spawn_type','target_type'}
        local tgt = {}

        for _,var in pairs(target_vars) do
            if target_entity[var] then
                tgt[var] = target_entity[var]
            end
        end

        if tgt.id == player.id then
            tgt.mp_percent = player.mp_percent
            tgt.tp = player.tp
        end

        if tgt.target_type then
            tgt.type = tgt.target_type
            tgt.target_type = nil
        end

        if tgt.status then
            tgt.status_id = tgt.status
            tgt.status = res.statuses[tgt.status_id].en
        end

        if tgt.race_id then
            tgt.race = res.races[tgt.race_id].en
        end

        if target_entity.position then
            tgt.x = target_entity.position.x
            tgt.y = target_entity.position.y
            tgt.z = target_entity.position.z
        end

        return tgt

    end

end

-- Parse an action packet and return an enriched table
local function parse_action(packet)

    local act = {}
    act.category = packet.action_category
    act.name = "Unknown"

    local category_name = statics.category_names[act.category]
    local resource_table
    if act.category == 0x10 then
        resource_table = {id="0",index="0",prefix="/range",english="Ranged",german="Fernwaffe",french="Attaque à dist.",japanese="飛び道具",type="Misc",element="None",targets={"Enemy"}}
    else
        resource_table = res[category_name][packet.param]
    end
    local action_vars = {'name','prefix','targets','type','skill','mp_cost','tp_cost','element','range','recast','recast_id','cast_time'}

    for _,v in pairs(action_vars) do
        if resource_table[v] then
            act[v] = resource_table[v]
        end
    end

    local skillchain_props = {'skillchain_a','skillchain_b','skillchain_c'}
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

----------------------------------------------------------------------------------------------------
-- CREATE USER ENVIRONMENT
----------------------------------------------------------------------------------------------------
local equip = function(set)
    local items = parse_set(set)
    inject_equipset_packet(items)
end

local user_env = {
    require=require,
    chat=chat,
    string=string,
    lua_base_path=windower.package_path,
    debug_msg=debug_msg,
    equip=equip,
}

local load_userscript = function(filename)

    local funct, err = loadfile(windower.package_path .. '\\'.. 'data' .. '\\' .. filename .. '.lua')
    if funct == nil then
        debug_msg('User File problem',err)
        return
    else
        debug_msg('Loading user script',filename)
    end

    setfenv(funct, user_env)

    local status, name = pcall(funct)
    if not status then
        debug_msg('Failed to load',name)
        return nil
    end

end

local user_pcall = function(str,...)
    if user_env then
        if type(user_env[str]) == 'function' then
            local bool,err = pcall(user_env[str],...)
            if not bool then
                debug_msg('Error in user function',str..' - '..err)
            end
        elseif user_env[str] then
            debug_msg('Not a function',str)
        end
    end
end


----------------------------------------------------------------------------------------------------
-- SET CONSTRUCTION FUNCTIONS
----------------------------------------------------------------------------------------------------

-- Return list of inventory matches based on item name
function match_item(item_name)

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
function valid_slots(item_id)
    local slot_map = statics.slot_map
    return slot_map[res.items[item_id].slots]
end

-- Enhance matches
function refine_matches(matches)

    local refined_match = {}

    for _,item in ipairs(matches) do
        if item then
            local valid_slot = valid_slots(item.id)[1]
            debug_msg('Equipping Item: '..res.items[item.id].enl..' ('..item.id..') in bag '..item.bag_id..' index '..item.bag_index..' to slot '..valid_slot)
            refined_match = {bag_index = item.bag_index, slot_id = valid_slot, bag_id = item.bag_id}
        else
            debug_msg('Item not found')
        end
    end

    return refined_match

end

-- Parse a table of equipment and return items
function parse_set(item_set)

    local items = {}

    for _,item_name in pairs(item_set) do
        local matches = match_item(item_name)
        local refined_match = refine_matches(matches)
        table.insert(items, refined_match)
    end

    return items

end

-- Inject packet for the assembled equipset
function inject_equipset_packet(items)

    local equip_packet = {
        count = 0,
        equipment = {},
    }

    for _,item in ipairs(items) do
        equip_packet.equipment[equip_packet.count] = item
        equip_packet.count = equip_packet.count + 1
    end

    packets.outgoing[0x051]:inject(equip_packet)

end

----------------------------------------------------------------------------------------------------
-- ACTION EVENT HANDLERS
----------------------------------------------------------------------------------------------------
action.filter_action:register(function(packet)
    -- action.block()
    local act = parse_action(packet)
    current_action = act
    user_pcall('filter_action',act)
end)

action.pre_action:register(function()
    user_pcall('pre_action',current_action)
end)

action.mid_action:register(function()
    user_pcall('mid_action',current_action)
end)

action.post_action:register(function()
    user_pcall('post_action',current_action)
end)

----------------------------------------------------------------------------------------------------
-- ADDON COMMANDS
----------------------------------------------------------------------------------------------------
local gs_command = command.new('gs')

gs_command:register('help', function()
    chat.add_text('GearSwap Help')
end)

gs_command:register('load', function(file_name)
    load_userscript(file_name)
end, '<file_name:text>')
gs_command:register('l', function(file_name)
    load_userscript(file_name)
end, '<file_name:text>')

gs_command:register('actionui', function()
    window_closed = not window_closed
end)

----------------------------------------------------------------------------------------------------
-- TEST COMMANDS
----------------------------------------------------------------------------------------------------
gs_command:register('equipitem', function(item_name)
    local matches = match_item(item_name)
    local item = {refine_matches(matches)}
    inject_equipset_packet(item)
end, '<item_name:text>')

gs_command:register('testset', function()
    local set = user_env.sets.idle
    local items = parse_set(set)
    inject_equipset_packet(items)
end)

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
