--[[
    me.lua
    Returns bot-stored userdata for the user. The bot owner may send a username
    or ID for that user's data.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local me = {}

function me:init()
    me.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('me', true).table
    me.command = 'me'
    me.doc = 'Returns user-specific information stored by the bot, such as nicknames or API usernames.'
end

function me:action(msg)
    local id_str = tostring(msg.from.id)
    if msg.from.id == self.config.admin then
        local input = utilities.get_word(msg.text, 2)
        if msg.reply_to_message then
            id_str = tostring(msg.reply_to_message.from.id)
        elseif input then
            if tonumber(input) then
                id_str = input
            elseif input:match('^@.') then
                local user = utilities.resolve_username(self, input)
                if user then
                    id_str = tostring(user.id)
                else
                    utilities.send_reply(msg, 'Unrecognized username.')
                    return
                end
            else
                utilities.send_reply(msg, 'Invalid ID or username.')
                return
            end
        end
    end

    local data = {}
    for key, tab in pairs(self.database.userdata) do
        if tab[id_str] ~= nil then
            table.insert(data, string.format('<b>%s:</b> <code>%s</code>',
                key,
                utilities.html_escape(tostring(tab[id_str]))
            ))
        end
    end
    local output
    if #data == 0 then
        output = 'There is no data stored for this user.'
    else
        output = '<b>' .. id_str .. '</b>\n' .. table.concat(data, '\n')
    end
    utilities.send_reply(msg, output, 'html')
end

return me
