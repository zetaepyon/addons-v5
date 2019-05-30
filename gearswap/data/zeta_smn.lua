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

filter_action = function(act)
    debug_msg('User Filter Action',act.name)
end

pre_action = function(act)
    debug_msg('User Pre-Action',act.name)
    if act.name == 'Shiva' then
        equip(sets.pre_action.Shiva)
    elseif act.name == 'Ifrit' then
        equip(sets.pre_action.Ifrit)
    end
end

mid_action = function(act)
    debug_msg('User Mid-Action',act.name)
end

post_action = function(act)
    debug_msg('User Post-Action',act.name)
    equip(sets.idle)
end