--[[
    deadmin.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('deadmin', true).table
    self.privilege = 5
    self.command = 'deadmin'
    self.doc = 'Demotes an administrator or administrators.'
    self.targeting = true
end

function P:action(bot, msg, _group, _user)
    local targets, output = autils.targets(bot, msg)
    for target, _ in pairs(targets) do
        local user = utilities.user(bot, target)
        if user.data.administrator then
            user.data.administrator = nil
            for chat_id, _ in pairs(bot.database.groupdata.admin) do
                if user:rank(bot, chat_id) < 2 then
                    autils.demote_admin(chat_id, target)
                end
            end
            table.insert(output, user:name() .. ' is no longer an administrator.')
        else
            table.insert(output, user:name() .. ' is not an administrator.')
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
