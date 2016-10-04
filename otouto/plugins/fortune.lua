 -- Requires that the "fortune" program is installed on your computer.

local fortune = {}

local utilities = require('otouto.utilities')

function fortune:init(config)
    local s = io.popen('fortune'):read('*all')
    assert(
        not s:match('not found$'),
        'fortune.lua requires the fortune program to be installed.'
    )
    fortune.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('fortune').table
end

fortune.command = 'fortune'
fortune.doc = 'Returns a UNIX fortune.'

function fortune:action(msg)
    local fortunef = io.popen('fortune')
    local output = '```\n' .. fortunef:read('*all') .. '\n```'
    fortunef:close()
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return fortune
