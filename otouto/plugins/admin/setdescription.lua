local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('setdescription', true):t('setdesc', true).table
    P.command = 'setdesc <text>'
    P.doc = 'Set a group description. Passing "--" will delete the current one.'
    P.privilege = 3
end

function P:action(msg, group) -- luacheck: ignore self
    local input = utilities.input_from_msg(msg)
    if not input then
        if group.description then
            utilities.send_reply(msg, '</b>Current description:</b>\n' ..
                group.description, 'html')
        else
            utilities.send_reply(msg, 'This group has no description.')
        end
    elseif input == '--' or input == utilities.char.em_dash then
        group.description = nil
        utilities.send_reply(msg, 'The group description has been cleared.')
    else
        group.description = input
        utilities.send_reply(msg, '<b>Description updated:</b>\n' ..
            group.description, 'html')
    end
end

return P
