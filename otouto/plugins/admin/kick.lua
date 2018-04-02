local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('kick', true):t('tempban', true).table
    self.command = 'kick'
    self.doc = "Removes a user or users from the group. A reason can be given \z
on a new line. Example:\
    /kick @examplus 5554321\
    Bad jokes."
    self.privilege = 2
    self.administration = true
    self.targeting = true
    self.duration = true
end

function P:action(bot, msg, _group, _user)
    local targets, output, reason, duration =
        autils.targets(bot, msg, {get_duration = true})
    local kicked_users = utilities.new_set()
    if duration and (duration > 366*24*60*60 or duration < 60) then
        duration = nil
        table.insert(output,
            'Durations must be longer than a minute and shorter than a year.')
    end

    local out_str, log_str
    if duration then
        out_str = ' has been banned for ' ..
            utilities.tiem.format(duration, true) .. '.'
        log_str = 'Banned for ' .. utilities.tiem.format(duration, true)
    else
        out_str = ' has been kicked.'
        log_str = 'Kicked'
    end

    if targets then
        for target in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            if autils.rank(bot, target, msg.chat.id) > 2 then
                table.insert(output, name .. ' is too privileged to be kicked.')
            else
                bindings.kickChatMember{
                    chat_id = msg.chat.id,
                    user_id = target,
                    until_date = duration and duration + os.time() or 45
                }
                table.insert(output, name .. out_str)
                kicked_users:add(target)
            end
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #kicked_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = kicked_users,
            action = log_str,
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
