--[[
    pokemon_go.lua
    Simple counter for the membership of Pokemon Go teams.

    Written by bb010g.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

-- For some reason you can't have an é in variable names. :(
local pokemon_go = {}

function pokemon_go:init()
    pokemon_go.command = 'pokego <team>'
    pokemon_go.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('pokego', true):t('pokégo', true)
        :t('pokemongo', true):t('pokémongo', true)
        :t('pogo', true):t('mongo', true).table
    pokemon_go.doc = self.config.cmd_pat .. [[pokego <team>
Set your Pokémon Go team for statistical purposes. The team must be valid, and can be referred to by name or color (or the first letter of either). Giving no team name will show statistics.]]
    local db = self.database.pokemon_go
    if not db then
        self.database.pokemon_go = {}
        db = self.database.pokemon_go
    end
    if not db.membership then
        db.membership = {}
    end
    for _, set in pairs(db.membership) do
            setmetatable(set, utilities.set_meta)
    end
end

local team_ref = {
    mystic = "Mystic",
    m = "Mystic",
    valor = "Valor",
    v = "Valor",
    instinct = "Instinct",
    i = "Instinct",
    blue = "Mystic",
    b = "Mystic",
    red = "Valor",
    r = "Valor",
    yellow = "Instinct",
    y = "Instinct"
}

function pokemon_go:action(msg)
    local output
    local input = utilities.input(msg.text_lower)

    if input then
        local team = team_ref[input]
        if not team then
            output = 'Invalid team.'
        else
            local id_str = tostring(msg.from.id)
            local db = self.database.pokemon_go
            local db_membership = db.membership
            if not db_membership[team] then
                db_membership[team] = utilities.new_set()
            end

            for t, set in pairs(db_membership) do
                if t ~= team then
                    set:remove(id_str)
                else
                    set:add(id_str)
                end
            end

            output = 'Your team is now '..team..'.'
        end
    else
        local db = self.database.pokemon_go
        local db_membership = db.membership

        local output_temp = {'Membership:'}
        for t, set in pairs(db_membership) do
            table.insert(output_temp, t..': '..#set)
        end

        output = table.concat(output_temp, '\n')
    end

    utilities.send_reply(msg, output)
end

return pokemon_go
