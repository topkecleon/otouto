--[[
    maybe.lua
    Runs a command, if it feels like it.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

local maybe = {}

function maybe:init()
    maybe.command = 'maybe <text>'
    maybe.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('maybe', true).table
    maybe.doc = self.config.cmd_pat .. [[maybe [int%] <command>
Runs a command sometimes (default 50% chance).]]
end

function maybe:action(msg)
    local probability, input = msg.text:match('^'..self.config.cmd_pat..'maybe%s+(%d*)%%?%s*(.+)')
    if not input then
        utilities.send_message(msg.chat.id, maybe.doc, true, msg.message_id, 'html')
    else
        probability = tonumber(probability) or 50
        if math.random() * 100 < probability then
            input = utilities.trim(input)
            msg.text = input
            bot.on_message(self, msg)
        end
    end
end

return maybe
