local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('mute', true).table
    P.command = 'mute'
    P.doc = [[Mute a user or users indefinitely or for the time specified in minutes. A single target can be specified by replying to one of his messages. Multiple targets can be specified via ID and username. In reply commands, the duration is specified after the command. Otherwise, the duration is specified on a new line after the targets. This behavior is consistent with ban reasons.
Examples:
    /mute @foo @bar 8675309
    120

    [in reply] /mute 240]]
    P.privilege = 2
    P.internal = true
    P.targeting = true
end

function P:action(msg, group)
    local targets, duration = autils.targets(self, msg)
    duration = tonumber(duration)

    -- Durations shorter than 30 seconds and longer than a leap year are
    -- interpreted as "forever" by the bot API.
    if duration and (duration > (366*24*60) or duration < 1) then
        duration = nil
    end

    local out_str, log_str
    if duration then
        out_str = ' has been muted for ' .. duration .. ' minutes.'
        log_str = 'Muted for ' .. duration .. ' minutes.'
    else
        out_str = ' has been muted.'
        log_str = 'Muted.'
    end

    local output = {}
    local muted_users = {} -- Passed to the log function at the end.

    if targets then
        for _, id in ipairs(targets) do
            if not tonumber(id) then
                table.insert(output, id)

            else
                local name = utilities.format_name(self, id)

                if autils.rank(self, id, msg.chat.id) > 1 then
                    table.insert(output,name..' is too privileged to be muted.')
                else
                    local a, b = bindings.restrictChatMember{
                        chat_id = msg.chat.id,
                        user_id = id,
                        until_date = duration and msg.date + (duration * 60),
                        can_send_messages = false
                    }
                    if not a then
                        table.insert(output, b.description .. ' (' .. id .. ')')
                    else
                        table.insert(output, name .. out_str)
                        table.insert(muted_users, id)
                    end
                end
            end
        end

    else
        table.insert(output, self.config.errors.specify_targets)
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #muted_users > 0 then
        autils.log(self, msg.chat.title, muted_users, log_str,
            utilities.format_name(self, msg.from.id))
    end
end

return P
