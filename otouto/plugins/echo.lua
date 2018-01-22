--[[
    echo.lua
    Returns input.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local echo = {}

function echo:init()
    echo.command = 'echo <text>'
    echo.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('echo', true).table
    echo.doc = self.config.cmd_pat .. 'echo <text> \nRepeats a string of text.'
end

function echo:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_message(msg.chat.id, echo.doc, true, msg.message_id, 'html')
    else
        local output
        if msg.chat.type == 'supergroup' then
            output = '<b>Echo:</b>\n"' .. utilities.html_escape(input) .. '"'
        else
            output = utilities.html_escape(utilities.char.zwnj..input)
        end
        utilities.send_message(msg.chat.id, output, true, nil, 'html')
    end
end

return echo
