local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('description', true):t('desc', true).table
    self.command = 'description [chat]'
end

function P:action(bot, msg, group)
    local input = utilities.input(msg.text_lower)
    local chat_id
    if input then
        for id_str, chat in pairs(bot.database.groupdata.admin) do
            if not chat.flags.private and chat.name:lower():match(input) then
                chat_id = id_str
                break
            end
        end
        if not chat_id then
            utilities.send_reply(msg, 'Group not found.')
            return
        end
    elseif group.data.admin then
        chat_id = msg.chat.id
    else
        utilities.send_reply(msg, 'Specify a group.')
        return
    end

    local description = self:desc(bot, chat_id)

    if msg.chat.id == msg.from.id then
        utilities.send_reply(msg, description, 'html')
    else
        if utilities.send_message(msg.from.id, description, true, nil, 'html') then
            utilities.send_reply(msg, 'I have sent you the requested information in a private message.')
        else
            utilities.send_reply(msg, description, 'html')
        end
    end
end

function P:desc(bot, chat_id)
    local admin = bot.database.groupdata.admin[tostring(chat_id)]

    local output = '<b>Welcome to '
    if admin.flags.private then
        output = output .. utilities.html_escape(admin.name) .. '!</b>'
    else
        output = output .. '</b><a href="' .. admin.link .. '">' ..
            utilities.html_escape(admin.name) .. '</a><b>!</b>'
    end

    output = output ..' <code>['.. utilities.normalize_id(chat_id) .. ']</code>'

    if admin.description then
        output = output .. '\n\n' .. admin.description
    end

    if #admin.rules > 0 then
        output = output .. '\n\n<b>Rules:</b>'
        for i, rule in ipairs(admin.rules) do
            output = output .. '\n<b>' .. i .. '.</b> ' .. rule
        end
    end

    if next(admin.flags) ~= nil then
        output = output .. '\n\n<b>Flags:</b>'
        for flag in pairs(admin.flags) do
            output = output .. '\n• ' .. bot.named_plugins['admin.flags'].flags[flag]
        end
    end

    output = output .. '\n\n<b>Governor:</b> ' ..
        utilities.lookup_name(bot, admin.governor)

    if next(admin.moderators) ~= nil then
        output = output .. '\n\n<b>Moderators:</b>'
        for id in pairs(admin.moderators) do
            output = output .. '\n• ' .. utilities.lookup_name(bot, id)
        end
    end

    return output
end

return P
