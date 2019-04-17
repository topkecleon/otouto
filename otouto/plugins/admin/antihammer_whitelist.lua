--[[
    antihammer_whitelist.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('antihammer', true).table
    self.command = 'antihammer'
    self.doc = "Returns a list of users who are protected from global bans in \z
this group, or toggle the status of a target or targets.."
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output = autils.targets(bot, msg)
    local admin = group.data.admin

    if #targets > 0 or #output > 0 then
        for target, _ in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            if admin.antihammer[target] then
                admin.antihammer[target] = nil
                table.insert(output, name ..
                    ' has been removed from the antihammer whitelist.')
            else
                admin.antihammer[target] = true
                table.insert(output, name ..
                    ' has been added to the antihammer whitelist.')
            end
        end

    elseif next(admin.antihammer) then
        table.insert(output, '<b>Antihammered users:</b>')
        table.insert(output, '• ' ..
            table.concat(utilities.list_names(bot, admin.antihammer), '\n• '))

    else
        table.insert(output, 'There are no antihammer-whitelisted users.')
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
