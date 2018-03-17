local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('groups', true):t('listgroups', true).table
    P.command = 'groups [query]'
    P.doc = [[/groups [query]
Returns a list of all public, administrated groups, or the results of a query.]]
end

function P:action(msg, group)
    local input = utilities.input_from_msg(msg)

    -- Output will be a list of results, a list of all groups, or an explanation
    -- that there are no (listed) groups.
    local results = {}
    local listed_groups = {}

    for _, group in pairs(self.database.administration.groups) do
        if not group.flags.private then
            local link = string.format('<a href="%s">%s</a>',
                group.link,
                utilities.html_escape(group.name)
            )
            table.insert(listed_groups, link)

            if input and group.name:lower():match(input) then
                table.insert(results, link)
            end
        end
    end

    local output

    if input then
        if #results == 0 then
            output = self.config.errors.results
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
        elseif group then
            if utilities.send_message(msg.from.id, group_list, true, nil, 'html') then
                output = 'I have sent you the requested information in a private message.'
            else
                output = string.format('Please <a href="https://t.me/%s?start=groups">message me privately</a> for a list of groups.', self.info.username)
            end
        else
            output = group_list
        end
    end

    utilities.send_reply(msg, output, 'html')
end

return P
