--[[
    starwars_crawl.lua
    Returns the opening "crawl" of a given Star Wars film.

    Based on a plugin by matthewhesketh.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local JSON = require('dkjson')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local starwars = {}

function starwars:init()
    starwars.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('starwars', true):t('sw', true).table
    starwars.doc = self.config.cmd_pat .. [[starwars <query>
Returns the opening crawl from the specified Star Wars film.
Alias: ]] .. self.config.cmd_pat .. 'sw'
    starwars.command = 'starwars <query>'
    starwars.base_url = 'http://swapi.co/api/films/'
end

local films_by_number = {
    ['phantom menace'] = 4,
    ['attack of the clones'] = 5,
    ['revenge of the sith'] = 6,
    ['new hope'] = 1,
    ['empire strikes back'] = 2,
    ['return of the jedi'] = 3,
    ['force awakens'] = 7
}

local corrected_numbers = {
    4,
    5,
    6,
    1,
    2,
    3,
    7
}

function starwars:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, starwars.doc, 'html')
        return
    end

    bindings.sendChatAction{chat_id = msg.chat.id, action = 'typing'}

    local film
    if tonumber(input) then
        input = tonumber(input)
        film = corrected_numbers[input] or input
    else
        for title, number in pairs(films_by_number) do
            if string.match(input, title) then
                film = number
                break
            end
        end
    end

    if not film then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local url = starwars.base_url .. film
    local jstr, code = HTTP.request(url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local output = '*' .. JSON.decode(jstr).opening_crawl .. '*'
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return starwars
