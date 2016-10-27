--[[
    cats.lua
    Returns photos of cats from thecatapi.com.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local cats = {}

function cats:init()
    if not self.config.thecatapi_key then
        print('Missing config value: thecatapi_key.')
        print('cats.lua will be enabled, but there are more features with a key.')
    end
    cats.url = 'http://thecatapi.com/api/images/get?format=html&type=jpg'
    if self.config.thecatapi_key then
        cats.url = cats.url .. '&api_key=' .. self.config.thecatapi_key
    end
    cats.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('cat').table
    cats.command = 'cat'
    cats.doc = 'Returns a cat!'
end

function cats:action(msg)
    local str, res = HTTP.request(cats.url)
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end
    str = str:match('<img src="(.-)">')
    bindings.sendPhoto{chat_id = msg.chat.id, photo = str}
end

return cats
