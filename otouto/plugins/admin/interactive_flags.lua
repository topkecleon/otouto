--[[
    interactive_flags.lua
    Toggle administrative flags interactively!

    Copyright 2019 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('extern.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    assert(bot.named_plugins['admin.flags'],
        self.name .. ' requires admin.flags!')

    self.command = 'flagint'
    self.doc = 'Enable or disable administrative flags.'
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('flags?int').table

    self.administration = true
    self.privilege = 3

    self.flags_plugin = bot.named_plugins['admin.flags']
end

function P:action(_, msg, group)
    local message = self:build_message(group)
    message.chat_id = msg.chat.id
    bindings.sendMessage(message)
end

function P:callback_action(bot, query)
    local group = utilities.group(bot, query.message.chat.id)
    local flag_name = utilities.get_word(query.data, 2)
    -- toggle flag
    if group.data.admin.flags[flag_name] then
        group.data.admin.flags[flag_name] = nil
    else
        group.data.admin.flags[flag_name] = true
    end
    -- build message update
    local message = self:build_message(group)
    message.chat_id = query.message.chat.id
    message.message_id = query.message.message_id
    bindings.editMessageText(message)
end

function P:build_message(group)
    local keyboard = utilities.keyboard('inline_keyboard'):row()
    local i = 0
    for flag_name in pairs(self.flags_plugin.flags) do
        local symbol = '❌ '
        if group.data.admin.flags[flag_name] then
            symbol = '✅ '
        end
        keyboard:button(symbol .. flag_name, 'callback_data', self.name .. ' ' .. flag_name)
        i = i + 1
        if i % 3 == 0 then
            keyboard:row()
        end
    end

    return {
        reply_markup = keyboard:serialize(),
        text = self.flags_plugin:list_flags(group.data.admin.flags),
        parse_mode = 'html'
    }
end

return P
