--[[
    dice.lua
    Returns a set of random numbers. Accepts D&D notation.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local dice = {}

function dice:init()
    dice.command = 'roll <nDr>'
    dice.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('roll', true).table
    dice.doc = self.config.cmd_pat .. [[roll <nDr>
Returns a set of dice rolls, where n is the number of rolls and r is the range. If only a range is given, returns only one roll.]]
end

function dice:action(msg)

    local input = utilities.input(msg.text_lower)
    if not input then
        utilities.send_message(msg.chat.id, dice.doc, true, msg.message_id, 'html')
        return
    end

    local count, range
    if input:match('^[%d]+d[%d]+$') then
        count, range = input:match('([%d]+)d([%d]+)')
    elseif input:match('^d?[%d]+$') then
        count = 1
        range = input:match('^d?([%d]+)$')
    else
        utilities.send_message(msg.chat.id, dice.doc, true, msg.message_id, 'html')
        return
    end

    count = tonumber(count)
    range = tonumber(range)

    if range < 2 then
        utilities.send_reply(msg, 'The minimum range is 2.')
        return
    end
    if range > 1000 or count > 1000 then
        utilities.send_reply(msg, 'The maximum range and count are 1000.')
        return
    end

    local output = '*' .. count .. 'd' .. range .. '*\n`'
    for _ = 1, count do
        output = output .. math.random(range) .. '\t'
    end
    output = output .. '`'

    utilities.send_message(msg.chat.id, output, true, msg.message_id, true)

end

return dice
