--[[
    demod.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('demod', true).table
    self.command = 'demod'
    self.doc = 'Demotes a moderator.'
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output = autils.targets(bot, msg)
    for target, _ in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        local admin = group.data.admin
        if autils.rank(bot, target, msg.chat.id) < 3 then
            autils.demote_admin(msg.chat.id, target)
        end
        if admin.moderators[target] then
            admin.moderators[target] = nil
            table.insert(output, name .. ' is no longer a moderator.')
        else
            table.insert(output, name .. ' is not a moderator.')
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
