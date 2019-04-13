--[[
    shout.lua
    Returns an obnoxious shout.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local anise = require('extern.anise')

local P = {}

function P:init(bot)
    self.command = 'shout <text>'
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat):t('shout', true).table
    self.doc = 'Shouts something. Input may be the replied-to message.'
    self.utf8_char = '('..utilities.char.utf_8..'*)'
end

function P:action(bot, msg)
    local input = utilities.input_from_msg(msg)
    if input then
        input = anise.trim(input):upper():gsub("\n", " ")
        local output = ''
        local inc = 0
        local ilen = 0
        for match in input:gmatch(self.utf8_char) do
            if ilen < 20 then
                ilen = ilen + 1
                output = output .. match .. ' '
            end
        end
        ilen = 0
        output = output .. '\n'
        for match in input:sub(2):gmatch(self.utf8_char) do
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
        output = '<code>' .. anise.trim(output) .. '</code>'
        utilities.send_message(msg.chat.id, output, true, false, 'html')
    else
        utilities.send_reply(msg, self.doc, 'html')
    end
end

return P

