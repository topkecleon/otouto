local lume = require('lume')

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('addgroup').table
    self.command = 'addgroup'
    self.doc = 'Adds the current supergroup to the administrative system.'

    self.privilege = 4
end

function P:action(bot, msg, group)
    local output

    if msg.chat.type ~= 'supergroup' then
        output = 'Administrated groups must be supergroups.'

    else
        local perms, group_owner
        local result = bindings.getChatAdministrators{ chat_id = msg.chat.id }
        for _, administrator in pairs(result.result) do
            if administrator.user.id == bot.info.id then
                perms = administrator
            elseif administrator.status == 'creator' then
                group_owner = administrator.user.id
            end
        end

        if not perms or not (
          perms.can_change_info and perms.can_delete_messages and
          perms.can_restrict_members and perms.can_promote_members and
          perms.can_invite_users
        ) then
            output =
                'I must have permission to change group info, delete messages,'
                .. ' and add, ban, and promote members.'
        elseif group then
            output = 'I am already administrating this group.'
        else
            local chat_id_str = tostring(msg.chat.id)
            bot.database.administration.groups[chat_id_str] = {
                name = msg.chat.title,
                link =
                    bindings.exportChatInviteLink{chat_id = msg.chat.id}.result,
                governor = group_owner or msg.from.id,
                owner = group_owner,
                rules = {},
                filter = {},
                antihammer = {},
                strikes = {},
                moderators = {},
                bans = {},
                flags = lume.clone(bot.config.administration.flags)
            }

            bindings.setChatDescription{
                chat_id = msg.chat.id,
                description = 'Welcome! Please review the rules and other group info with '
                    .. bot.config.cmd_pat .. 'description@' ..
                    bot.info.username .. '.'
            }

            output = 'I am now administrating this group.'
        end
    end

    utilities.send_reply(msg, output)
end

return P
