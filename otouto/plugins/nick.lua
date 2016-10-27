--[[
    nick.lua
    Allows a user to set a nickname to be used by various plugins. Nicknames are
    stored in userdata.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local nick = {}

function nick:init()
    nick.command = 'nick <nickname>'
    nick.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('nick', true).table
    nick.doc = self.config.cmd_pat .. [[nick <nickname>
Set your nickname. Use "]] .. self.config.cmd_pat .. 'nick --" to delete it.'
    self.database.userdata.nick = self.database.userdata.nick or {}
end

function nick:action(msg)

    local id_str, name

    if msg.from.id == self.config.admin and msg.reply_to_message then
        id_str = tostring(msg.reply_to_message.from.id)
        name = utilities.build_name(msg.reply_to_message.from.first_name, msg.reply_to_message.from.last_name)
    else
        id_str = tostring(msg.from.id)
        name = utilities.build_name(msg.from.first_name, msg.from.last_name)
    end

    local output
    local input = utilities.input(msg.text)
    if not input then
        if self.database.userdata.nick[id_str] then
            output = name .. '\'s nickname is "' .. self.database.userdata.nick[id_str] .. '".'
        else
            output = name .. ' currently has no nickname.'
        end
    elseif utilities.utf8_len(input) > 32 then
        output = 'The character limit for nicknames is 32.'
    elseif input == '--' or input == utilities.char.em_dash then
        self.database.userdata.nick[id_str] = nil
        output = name .. '\'s nickname has been deleted.'
    else
        input = input:gsub('\n', ' ')
        self.database.userdata.nick[id_str] = input
        output = name .. '\'s nickname has been set to "' .. input .. '".'
    end

    utilities.send_reply(msg, output)

end

return nick
