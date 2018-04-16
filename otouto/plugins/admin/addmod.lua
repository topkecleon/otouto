--[[
    addmod.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('mod', true):t('addmod', true):t('op', true).table
    self.command = 'addmod'
    self.doc = 'Promotes a user to a moderator.'
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output = autils.targets(bot, msg, {unknown_ids_err = true})
    for target in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        local rank = autils.rank(bot, target, msg.chat.id)

        if rank > 2 then
            autils.promote_admin(msg.chat.id, target, true)
            table.insert(output, name ..' is greater than a moderator.')
        else
            autils.promote_admin(msg.chat.id, target)
            local admin = group.data.admin
            if admin.moderators[target] then
                table.insert(output, name .. ' is already a moderator.')
            else
                admin.moderators[target] = true
                admin.bans[target] = nil
                table.insert(output, name .. ' is now a moderator.')
            end
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
