--[[
    urbandictionary.lua
    Returns the top Urban Dictionary entry for a given query.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local urbandictionary = {}

function urbandictionary:init()
    urbandictionary.command = 'urbandictionary <query>'
    urbandictionary.base_url = 'http://api.urbandictionary.com/v0/define?term='
    urbandictionary.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('urbandictionary', true):t('ud', true):t('urban', true).table
    urbandictionary.doc = [[/urbandictionary <query>
Returns a definition from Urban Dictionary.
Aliases: /ud, /urban]]
    urbandictionary.doc = urbandictionary.doc:gsub('/', self.config.cmd_pat)
end

function urbandictionary:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, urbandictionary.doc, 'html')
        return
    end

    local url = urbandictionary.base_url .. URL.escape(input)
    local old_timeout = HTTP.TIMEOUT
    HTTP.TIMEOUT = 1
    local jstr, code = HTTP.request(url)
    HTTP.TIMEOUT = old_timeout
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    local output
    if data.result_type == 'no_results' then
        output = self.config.errors.results
    else
        output = string.format('<b>%s</b>\n\n%s\n\n<i>%s</i>',
            utilities.html_escape(data.list[1].word),
            utilities.trim(utilities.html_escape(data.list[1].definition)),
            utilities.trim(utilities.html_escape(data.list[1].example or ''))
        )
    end
    utilities.send_reply(msg, output, 'html')
end

return urbandictionary
