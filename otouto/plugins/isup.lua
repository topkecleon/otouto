--[[
    isup.lua
    Returns the status of a given website.

    Based on a plugin by matthewhesketh.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--
local http = require('socket.http')
local https = require('ssl.https')
local utilities = require('otouto.utilities')

local isup = {}

function isup:init()
    isup.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('websitedown', true):t('isitup', true):t('isup', true).table

    isup.doc = self.config.cmd_pat .. [[isup <url>
Returns the up or down status of a website.]]
    isup.command = 'isup <url>'
end

function isup:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, isup.doc, 'html')
        return
    end

    local protocol = input:lower():match('^https://') and https or http
    local old_timeout = protocol.TIMEOUT
    protocol.TIMEOUT = 2
    local _, code = protocol.request(input)
    protocol.TIMEOUT = old_timeout
    code = tonumber(code)
    local output
    if not code or code > 399 then
        output = 'This website is down or nonexistent.'
    else
        output = 'This website is up.'
    end
    utilities.send_reply(msg, output, true)
end

return isup
