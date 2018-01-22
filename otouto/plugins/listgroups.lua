local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('groups', true):t('listgroups', true).table
    P.command = 'groups [query]'
    P.doc = [[/groups [query]
Returns a list of all public, administrated groups, or the results of a query.]]
end

function P:action(msg)
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

    -- If $results is populated, then there was a query; we return results.
    if #results > 0 then
        output = string.format('<b>Groups matching</b> <i>%s</i><b>:</b>\n• %s',
            utilities.html_escape(input),
            table.concat(results, '\n• ')
        )

    elseif #listed_groups > 0 then
        output = '<b>Groups:</b>\n• ' .. table.concat(listed_groups, '\n• ')

    else
        output = 'There are no listed groups.'
    end

    utilities.send_reply(msg, output, 'html')
end

return P
