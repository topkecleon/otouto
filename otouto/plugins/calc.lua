--[[
    calc.lua
    Runs mathematical expressions through the mathjs.org API.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local URL = require('socket.url')
local HTTPS = require('ssl.https')
local utilities = require('otouto.utilities')

local calc = {}

function calc:init()
    calc.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('calc', true).table
    calc.doc = self.config.cmd_pat .. [[calc <expression>
Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.]]
    calc.command = 'calc <expression>'
end

function calc:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, calc.doc, 'html')
        return
    end

    local url = 'https://api.mathjs.org/v1/?expr=' .. URL.escape(input)
    local output = HTTPS.request(url)
    output = output and '`'..output..'`' or self.config.errors.connection
    utilities.send_reply(msg, output, true)
end

return calc
