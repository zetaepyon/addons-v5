return {

    category_names = {
        [3] = 'spells',
        [7] = 'weapon_skills',
        [9] = 'job_abilities',
        [14] = 'ranged_attack'
    },

    equippable_bags = {0,8,10,11,12},
    usable_bags = {3,0,8,10,11,12},

    slot_map = {
        [1] = {0},         -- Main
        [2] = {1},         -- Sub
        [3] = {0,1},       -- Main, Sub
        [4] = {2},         -- Range
        [8] = {3},         -- Ammo
        [16] = {4},        -- Head
        [32] = {5},        -- Body
        [64] = {6},        -- Hands
        [128] = {7},       -- Legs
        [256] = {8},       -- Feet
        [512] = {9},       -- Neck
        [1024] = {10},     -- Waist
        [6144] = {11,12},  -- Ears
        [24576] = {13,14}, -- Rings
        [32768] = {15},    -- Back
    },

    slot_name_map = {
        main = 0,
        sub = 1,
        range = 2,
        ranged = 2,
        ammo = 3,
        head = 4,
        body = 5,
        hands = 6,
        legs = 7,
        feet = 8,
        neck = 9,
        waist = 10,
        ear1 = 11,
        ear2 = 12,
        left_ear = 11,
        right_ear = 12,
        learring = 11,
        rearring = 12,
        lear = 11,
        rear = 12,
        ring1 = 13,
        ring2 = 14,
        left_ring = 13,
        right_ring = 14,
        lring = 13,
        rring = 14,
        back = 15,
    },
}

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
