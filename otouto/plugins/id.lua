local utilities = require('otouto.utilities')

local id = {}

function id:init(config)
    id.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('id', true).table
    id.command = 'id <user>'
    id.doc = config.cmd_pat .. [[id <user> ...
Returns the name, ID, and username (if applicable) for the given users.
Arguments must be usernames and/or IDs. Input is also accepted via reply. If no input is given, returns info for the user.
    ]]
end

function id.format(t)
    if t.username then
        return string.format(
            '@%s, AKA <b>%s</b> <code>[%s]</code>.\n',
            t.username,
            utilities.build_name(t.first_name, t.last_name),
            t.id
        )
    else
        return string.format(
            '<b>%s</b> <code>[%s]</code>.\n',
            utilities.build_name(t.first_name, t.last_name),
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
    utilities.send_reply(self, msg, output, 'html')
end

return id
