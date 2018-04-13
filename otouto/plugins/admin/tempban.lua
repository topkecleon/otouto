local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('tempban', true).table
    self.command = 'tempban'
    self.doc = "Bans a user or users. A duration must be given on a new line \z
(or after the command in a reply). A reason can be given after that. Example:\
    /tempban @examplus 5554321\
    3d12h Bad jokes."
    self.privilege = 2
    self.administration = true
    self.targeting = true
    self.duration = true
end

function P:action(bot, msg, _group, _user)
    local targets, output, reason, duration =
        autils.targets(bot, msg, {get_duration = true})
    local banned_users = utilities.new_set()

    if not duration or duration > 366*24*60*60 or duration < 60 then
        table.insert(output,
            'Durations must be longer than a minute and shorter than a year.')
    else
        for target in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            if autils.rank(bot, target, msg.chat.id) > 2 then
                table.insert(output, name .. ' is too privileged to be banned.')
            else
                local success, result = bindings.kickChatMember{
                    chat_id = msg.chat.id,
                    user_id = target,
                    until_date = duration + os.time()
                }
                if success then
                    table.insert(output, name .. ' has been banned for ' ..
                        utilities.tiem.format(duration) .. '.')
                    banned_users:add(target)
                else
                    table.insert(output, 'Error banning ' .. name .. ': ' ..
                        result.description)
                end
            end
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #banned_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = banned_users,
            action = 'Banned for '..utilities.tiem.format(duration),
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
