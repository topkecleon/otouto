--[[
    catfact.lua
    Returns cat facts.

    Based on a plugin by matthewhesketh.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local dkjson = require('dkjson')
local https = require('ssl.https')
local utilities = require('otouto.utilities')

local catfact = {}

function catfact:init()
    catfact.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('catfact', true).table
    catfact.command = 'catfact'
    catfact.doc = 'Returns a cat fact from catfact.ninja.'
    catfact.url = 'https://catfact.ninja/fact'
end

function catfact:action(msg)
    local jstr, code = https.request(catfact.url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end
    local data = dkjson.decode(jstr)
    local output = '*Cat Fact*\n_' .. data.fact .. '_'
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return catfact
