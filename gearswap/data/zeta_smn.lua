sets = {}
sets.pre_action = {}
sets.pre_action.Shiva = {
    main = "Hvergelmir",
    head = "Summoner's Horn",
    body = "Summoner's Doublet",
    hands = "Summoner's Bracers",
    legs = "Summoner's Spats",
    feet = "Summoner's Pigaches",
}

sets.pre_action.Ifrit = {
    "Beckoner's Bracers +1",
    "Hvergelmir",
    "Beckoner's Doublet +1",
    "Beckoner's Horn +1",
    "Beckoner's Spats +1",
    feet = "Beckoner's Pigaches +1",
}

sets.idle = {
    "Hvergelmir",
    "Summoner's Horn",
    "Mithran Separates",
    "Mithran Gauntlets",
    "Mithran Loincloth",
    "Mithran Gaiters",
    "Defending Ring",
}

filter_action = function(action)
    debug.message('User Filter Action',action.name)
end

pre_action = function(action)
    debug.message('User Pre-Action',action.name)
    if action.name == 'Shiva' then
        equip(sets.pre_action.Shiva)
    elseif action.name == 'Ifrit' then
        equip(sets.pre_action.Ifrit)
    end
end

mid_action = function(action)
    debug.message('User Mid-Action',action.name)
end

post_action = function(action)
    debug.message('User Post-Action',action.name)
    equip(sets.idle)
end