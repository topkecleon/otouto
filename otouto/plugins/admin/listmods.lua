local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('mods'):t('ops').table
    P.command = 'mods'
    P.doc = 'Returns a list of group moderators.'
    P.administration = true
end

function P:action(msg, group)
    local output = '<b>Governor:</b> ' ..
        utilities.format_name(self, group.governor)
    if next(group.moderators) ~= nil then
        local mod_list = {}
        for id_str in pairs(group.moderators) do
            table.insert(mod_list, utilities.format_name(self, id_str))
        end
        output = output ..  '\n\n<b>Moderators:</b>\n• ' ..
            table.concat(mod_list, '\n• ')
    end
    utilities.send_reply(msg, output, 'html')
end

return P
