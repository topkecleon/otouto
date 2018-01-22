--[[
    catfact.lua
    Returns cat facts.

    Based on a plugin by matthewhesketh.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local JSON = require('dkjson')
local HTTP = require('socket.http')
local utilities = require('otouto.utilities')

local catfact = {name = 'catfact'}

function catfact:init()
    catfact.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('catfact', true).table
    catfact.command = 'catfact'
    catfact.doc = 'Returns a cat fact.'
    catfact.url = 'http://catfacts-api.appspot.com/api/facts'
end

function catfact:action(msg)
    local jstr, code = HTTP.request(catfact.url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end
    local data = JSON.decode(jstr)
    local output = '*Cat Fact*\n_' .. data.facts[1] .. '_'
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return catfact
