local me = {}

local utilities = require('otouto.utilities')

function me:init(config)
    me.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('me', true).table
    me.command = 'me'
    me.doc = 'Returns userdata stored by the bot.'
end

function me:action(msg, config)
    local user
    if msg.from.id == config.admin then
        if msg.reply_to_message then
            user = msg.reply_to_message.from
        else
            local input = utilities.input(msg.text)
            if input then
                if tonumber(input) then
                    user = self.database.users[input]
                    if not user then
                        utilities.send_reply(msg, 'Unrecognized ID.')
                        return
                    end
                elseif input:match('^@') then
                    user = utilities.resolve_username(self, input)
                    if not user then
                        utilities.send_reply(msg, 'Unrecognized username.')
                        return
                    end
                else
                    utilities.send_reply(msg, 'Invalid username or ID.')
                    return
                end
            end
        end
    end
    user = user or msg.from
    local userdata = self.database.userdata[tostring(user.id)] or {}

    local data = {}
    for k,v in pairs(userdata) do
        table.insert(data, string.format(
            '<b>%s:</b> <code>%s</code>\n',
            utilities.html_escape(k),
            utilities.html_escape(v)
        ))
    end

    local output
    if #data == 0 then
        output = 'There is no data stored for this user.'
    else
        output = string.format(
            '<b>%s</b> <code>[%s]</code><b>:</b>\n',
            utilities.html_escape(utilities.build_name(
                user.first_name,
                user.last_name
            )),
            user.id
        ) .. table.concat(data)
    end

    utilities.send_message(msg.chat.id, output, true, nil, 'html')

end

return me
