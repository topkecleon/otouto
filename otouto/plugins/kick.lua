local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('kick', true).table
    P.command = 'kick'
    P.doc = [[Removes a user or users from the group. Targets will be unable to rejoin for one minute. A reason can be given on a new line. Example:
    /kick @examplus 5554321
    Bad jokes.]]
    P.privilege = 2
    P.internal = true
    P.targeting = true
end

function P:action(msg, group, user)
    local targets, reason = autils.targets(self, msg)
    local output = {}
    local kicked_users = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(self, id)
                if autils.rank(self, id) > 2 then
                    table.insert(output, name .. ' is too privileged to be kicked.')
                else
                    bindings.kickChatMember{
                        chat_id = msg.chat.id,
                        user_id = id,
                        until_date = msg.date + 60
                    }
                    table.insert(output, name .. ' has been kicked.')
                    table.insert(kicked_users, id)
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #kicked_users > 0 then
        autils.log(self, msg.chat.title, kicked_users, 'Kicked for one minute.',
            utilities.format_name(self, msg.from.id), reason)
    end
end

return P
