local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('mods'):t('ops').table
    self.command = 'mods'
    self.doc = 'Returns a list of group moderators.'
    self.administration = true
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    local output = '<b>Governor:</b> ' ..
        utilities.format_name(bot, admin.governor)
    if next(admin.moderators) ~= nil then
        local mod_list = {}
        for id_str in pairs(admin.moderators) do
            table.insert(mod_list, utilities.format_name(bot, id_str))
        end
        output = output ..  '\n\n<b>Moderators:</b>\n• ' ..
            table.concat(mod_list, '\n• ')
    end
    utilities.send_reply(msg, output, 'html')
end

return P
