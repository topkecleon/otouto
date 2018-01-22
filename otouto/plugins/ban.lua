local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('ban', true).table
    P.command = 'ban*'
    P.privilege = 2
    P.internal = true
end

function P:action(msg, group)
    local targets, reason = autils.targets(self, msg)
    local output = {}
    local banned_users = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(self, id)
                if autils.rank(self, id) > 2 then
                    table.insert(output, name .. ' is too privileged to be banned.')
                elseif group.bans[tostring(id)] then
                    table.insert(output, name .. ' is already banned.')
                else
                    group.bans[tostring(id)] = true
                    bindings.kickChatMember{
                        chat_id = msg.chat.id,
                        user_id = id
                    }
                    table.insert(output, name .. ' has been banned.')
                    table.insert(banned_users, id)
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #banned_users > 0 then
        autils.log(self, msg.chat.title, banned_users, 'Banned.',
            utilities.format_name(self, msg.from.id))
    end
end

return P
