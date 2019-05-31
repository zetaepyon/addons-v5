local chat = require('chat')
local string = require('string')
local windower = require('windower')

local debug
debug = {

    message = function(title, data)
        data = data or ''
        chat.add_text('GS>> ' .. title .. ': ' .. data, 8)
    end,

    stringify = function(tbl, indent)
        local stringy = ''
        if not indent then indent = 0 end
        for k,v in pairs(tbl) do
            local formatting = string.rep("    ", indent) .. k .. ": "
            if type(v) == 'table' then
                stringy = stringy .. formatting .. '\n' .. debug.stringify(v, indent + 1)
            else
                stringy = stringy .. formatting .. tostring(v) .. '\n'
            end
        end
        return stringy
    end,

    window = {
        title = 'Last Gearswap Action',
        x = windower.settings.ui_size.width - 300,
        y = windower.settings.ui_size.height / 2 - 300,
        width = 200,
        height = 600,
        moveable = true,
        closed = true,
    },

}

return debug

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
