--[[
    kick.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local anise = require('anise')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('kick', true).table
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
    local targets, output, reason = autils.targets(bot, msg)
    local kicked_users = anise.set()

    for target, _ in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        if autils.rank(bot, target, msg.chat.id) >= 2 then
            table.insert(output, name .. ' is too privileged to be kicked.')
        else
            -- It isn't documented, but unbanChatMember also kicks.
            -- Thanks, Durov.
            local success, result = bindings.unbanChatMember{
                chat_id = msg.chat.id,
                user_id = target
            }
            if success then
                table.insert(output, name .. ' has been kicked.')
                kicked_users:add(target, reason or true)
            else
                table.insert(output, 'Error kicking ' .. name .. ': ' ..
                    result.description)
            end
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #kicked_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = kicked_users,
            action = 'Kicked',
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
