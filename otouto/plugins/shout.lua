--[[
    shout.lua
    Returns an obnoxious shout.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local shout = {}

local utf8_char = '('..utilities.char.utf_8..'*)'

function shout:init()
    shout.command = 'shout <text>'
    shout.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('shout', true).table
    shout.doc = self.config.cmd_pat .. 'shout <text> \nShouts something. Input may be the replied-to message.'
end

function shout:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, shout.doc, 'html')
        return
    end

    input = utilities.trim(input)
    input = input:upper():gsub("\n", " ")

    local output = ''
    local inc = 0
    local ilen = 0
    for match in input:gmatch(utf8_char) do
        if ilen < 20 then
            ilen = ilen + 1
            output = output .. match .. ' '
        end
    end
    ilen = 0
    output = output .. '\n'
    for match in input:sub(2):gmatch(utf8_char) do
        if ilen < 19 then
            local spacing = ''
            for _ = 1, inc do
                spacing = spacing .. '  '
            end
            inc = inc + 1
            ilen = ilen + 1
            output = output .. match .. ' ' .. spacing .. match .. '\n'
        end
    end
    output = '```\n' .. utilities.trim(output) .. '\n```'
    utilities.send_message(msg.chat.id, output, true, false, true)
end

return shout
