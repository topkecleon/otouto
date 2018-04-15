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
            if not chat.flags.private and
                bot.database.groupdata.info[id_str].title:find(input, 1, true) then
                    chat_id = id_str
                    break
            end
        end
        if not chat_id then
            utilities.send_reply(msg, 'Group not found.')
            return
        end
    elseif group and group.data.admin then
        chat_id = msg.chat.id
    else
        utilities.send_reply(msg, 'Specify a group.')
        return
    end

    local description = self.desc(bot, chat_id)

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

function P.desc(bot, chat_id)
    local admin = bot.database.groupdata.admin[tostring(chat_id)]
    local output = {}

    -- Group title
    table.insert(output, utilities.lookup_name(bot, chat_id))

    -- Description
    table.insert(output, admin.description)

    -- Rules
    if #admin.rules > 0 then
        table.insert(output, '<b>Rules:</b>\n' .. table.concat(
            bot.named_plugins['admin.listrules'].rule_list(admin.rules), '\n'))
    end

    -- Flags
    if next(admin.flags) ~= nil then
        table.insert(output, '<b>Flags:</b>\n• ' .. table.concat(
            bot.named_plugins['admin.flags']:flag_list(admin.flags), '\n• '))
    end

    -- Governor
    table.insert(output, '<b>Governor:</b> ' ..
        utilities.lookup_name(bot, admin.governor))

    -- Moderators
    if next(admin.moderators) ~= nil then
        table.insert(output, '<b>Moderators:</b>\n• ' .. table.concat(
            utilities.list_names(bot, admin.moderators), '\n• '))
    end

    return table.concat(output, '\n\n')
end

return P
