--[[
    fortune.lua
    Returns UNIX fortunes.

    Requires that the "fortune" program is installed on your computer.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local fortune = {}

function fortune:init()
    local s = io.popen('fortune'):read('*all')
    assert(
        not s:match('not found$'),
        'fortune.lua requires the fortune program to be installed.'
    )
    fortune.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('fortune').table
    fortune.command = 'fortune'
    fortune.doc = 'Returns a UNIX fortune.'
end

function fortune:action(msg)
    local fortunef = io.popen('fortune')
    local output = '```\n' .. fortunef:read('*all') .. '\n```'
    fortunef:close()
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return fortune
