--[[
    unhammer.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local anise = require('anise')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('unhammer', true).table
    self.command = 'unhammer'
    self.privilege = 4
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output, reason = autils.targets(bot, msg)
    local unhammered_users = anise.set()

    for target, _ in pairs(targets) do
        local user = utilities.user(bot, target)
        -- Reset the global antilink counter.
        user.data.antilink = nil
        if user.data.hammered then
            user.data.hammered = nil
            unhammered_users:add(target, reason or true)
            table.insert(output, user:name() .. ' is no longer globally banned.')
        else
            table.insert(output, user:name() .. ' is not globally banned.')
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #unhammered_users > 0 then
        autils.log(bot, {
            -- Do not send the chat ID from PMs or private groups.
            chat_id = group and group.data.admin
                and not group.data.admin.flags.private and msg.chat.id,
            targets = unhammered_users,
            action = "Unhammered",
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
