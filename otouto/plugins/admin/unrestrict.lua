local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('unrestrict', true):t('unmute', true):t('unban', true).table
    self.command = 'unrestrict'
    self.doc = 'Unrestrict a user.\nAliases: ' .. bot.config.cmd_pat .. 'unmute, '
        .. bot.config.cmd_pat .. 'unban'
    self.privilege = 2
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets = autils.targets(bot, msg)
    local output = {}
    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                bindings.restrictChatMember{
                    chat_id = msg.chat.id,
                    user_id = id,
                    can_send_other_messages = true,
                    can_add_web_page_previews = true
                }
                if bot.database.administration.automoderation[tostring(msg.chat.id)] then
                    bot.database.administration.automoderation[tostring(msg.chat.id)][tostring(id)] = nil
                end
                if group.bans[tostring(id)] then
                    group.bans[tostring(id)] = nil
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' has been unbanned and unrestricted.')
                elseif bot.database.administration.hammers[tostring(id)] then
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' is globally banned.')
                else
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' has been unrestricted.')
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
