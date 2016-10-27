--[[
    shell.lua
    Allows the execution of non-interactive shell commands by the bot owner.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local shell = {}

function shell:init()
    shell.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('run', true).table
end

function shell:action(msg)

    if msg.from.id ~= self.config.admin then
        return
    end

    local input = utilities.input(msg.text)
    input = input:gsub('—', '--')

    if not input then
        utilities.send_reply(msg, 'Please specify a command to run.')
        return
    end

    local f = io.popen(input)
    local output = f:read('*all')
    f:close()
    if output:len() == 0 then
        output = 'Done!'
    else
        output = '```\n' .. output .. '\n```'
    end
    utilities.send_message(msg.chat.id, output, true, msg.message_id, true)

end

return shell
