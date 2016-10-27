--[[
    chuckfact.lua
    Returns $100% true facts about Chuck Norris.

    Based on a plugin by matthewhesketh.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local JSON = require('dkjson')
local HTTP = require('socket.http')
local utilities = require('otouto.utilities')

local chuck = {}

function chuck:init()
    chuck.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('chuck', true):t('cn', true):t('chucknorris', true).table
    chuck.command = 'chuck'
    chuck.doc = 'Returns a fact about Chuck Norris.'
    chuck.url = 'http://api.icndb.com/jokes/random'
end

function chuck:action(msg)
    local jstr, code = HTTP.request(chuck.url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end
    local data = JSON.decode(jstr)
    local output = '*Chuck Norris Fact*\n_' .. data.value.joke .. '_'
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return chuck
