--[[
    regenlink.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('regenlink').table
    self.command = 'regenlink'
    self.doc = 'Regenerates the group link.'
    self.administration = true
    self.privilege = 2
end

function P:action(_bot, msg, group)
    local success, result = bindings.exportChatInviteLink{chat_id = msg.chat.id}
    if success then
        group.data.admin.link = result.result
        utilities.send_reply(msg, 'The link has been regenerated.')
    else
        utilities.send_reply(msg, result.description)
    end
end

return P
