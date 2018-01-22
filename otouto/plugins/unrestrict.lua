local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('unrestrict', true):t('unmute', true):t('unban', true).table
    P.command = 'unrestrict*'
    P.doc = 'Unrestrict a user.\nAliases: ' .. self.config.cmd_pat .. 'unmute, '
        .. self.config.cmd_pat .. 'unban'
    P.privilege = 2
    P.internal = true
end

function P:action(msg, group)
    local targets = autils.targets(self, msg)
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
                self.database.administration.automoderation[tostring(msg.chat.id)][tostring(id)] = nil
                if group.bans[tostring(id)] then
                    group.bans[tostring(id)] = nil
                    table.insert(output, utilities.format_name(self, id) ..
                        ' has been unbanned and unrestricted.')
                else
                    table.insert(output, utilities.format_name(self, id) ..
                        ' has been unrestricted.')
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
