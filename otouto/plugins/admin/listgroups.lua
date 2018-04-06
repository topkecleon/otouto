local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('groups', true):t('listgroups', true).table
    self.command = 'groups [query]'
    self.doc = "/groups [query]\
Returns a list of all public, administrated groups, or the results of a query."
end

function P:action(bot, msg, _group)
    local input = utilities.input_from_msg(msg)

    -- Output will be a list of results, a list of all groups, or an explanation
    -- that there are no (listed) groups.
    local results, listed_groups = {}, {}

    for id_str, chat in pairs(bot.database.groupdata.admin) do
        local title = bot.database.groupdata.info[id_str].title
        if not chat.flags.private then
            local link = string.format(
                '<a href="%s">%s</a>',
                chat.link,
                utilities.html_escape(title)
            )
            table.insert(listed_groups, link)

            if input and title:lower():match(input) then
                table.insert(results, link)
            end
        end
    end

    local output

    if input then
        if #results == 0 then
            output = bot.config.errors.results
        else
            output = string.format(
                '<b>Groups matching</b> <i>%s</i><b>:</b>\n• %s',
                utilities.html_escape(input),
                table.concat(results, '\n• ')
            )
        end
    else
        local group_list =
            '<b>Groups:</b>\n• ' .. table.concat(listed_groups, '\n• ')
        if #listed_groups == 0 then
            output = 'There are no listed groups.'
        else
            if utilities.send_message(msg.from.id, group_list, true, nil, 'html') then
                if msg.chat.id == msg.from.id then
                    output = 'I have sent you the requested information in a private message.'
                end
            else
                output = string.format(
                    'Please <a href="https://t.me/%s?start=groups">message me privately</a> for a list of groups.',
                    bot.info.username
                )
            end
        end
    end

    if output then utilities.send_reply(msg, output, 'html') end
end

return P
