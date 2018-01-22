--[[
    id.lua
    Returns usernames, IDs, and display names of given users.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local id = {}

function id:init()
    assert(
        self.named_plugins.users or self.named_plugins.administration,
        'This plugin requires users.lua or administration.lua to be loaded first.'
    )
    id.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('id', true).table
    id.command = 'id <user>'
    id.doc = self.config.cmd_pat .. [[id <user> ...
Returns the name, ID, and username (if applicable) for the given users.
Arguments must be usernames and/or IDs. Input is also accepted via reply. If no input is given, returns info for the user.
    ]]
end

function id.format(t)
    if t.username then
        return string.format(
            '@%s, AKA <b>%s</b> <code>[%s]</code>.\n',
            t.username,
            utilities.html_escape(utilities.build_name(t.first_name, t.last_name)),
            t.id
        )
    else
        return string.format(
            '<b>%s</b> <code>[%s]</code>.\n',
            utilities.html_escape(utilities.build_name(t.first_name, t.last_name)),
            t.id
        )
    end
end

function id:action(msg)
    local output
    local input = utilities.input(msg.text)
    if msg.reply_to_message then
        output = id.format(msg.reply_to_message.from)
    elseif input then
        output = ''
        for user in input:gmatch('%g+') do
            if tonumber(user) then
                if self.database.users[user] then
                    output = output .. id.format(self.database.users[user])
                else
                    output = output .. 'I don\'t recognize that ID (' .. user .. ').\n'
                end
            elseif user:match('^@') then
                local t = utilities.resolve_username(self, user)
                if t then
                    output = output .. id.format(t)
                else
                    output = output .. 'I don\'t recognize that username (' .. user .. ').\n'
                end
            else
                output = output .. 'Invalid username or ID (' .. user .. ').\n'
            end
        end
    else
        output = id.format(msg.from)
    end
    utilities.send_reply(msg, output, 'html')
end

return id
