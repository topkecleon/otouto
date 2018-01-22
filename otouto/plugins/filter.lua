local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('filter', true).table
    P.command = 'filter [term]'
    P.doc = 'Adds or removes a filter, or lists all filters. Messages containing filtered terms are deleted. Filters use Lua patterns.'
    P.privilege = 3
    P.internal = true
end

function P:action(msg, group, user)
    local input = utilities.input(msg.text_lower)
    local output
    if input then
        local idx
        for i = 1, #group.filter do
            if group.filter[i] == input then
                idx = i
                break
            end
        end
        if idx then
            table.remove(group.filter, idx)
            output = 'That term has been removed from the filter.'
        else
            table.insert(group.filter, input)
            output = 'That term has been added to the filter.'
        end
    elseif #group.filter == 0 then
        output = 'There are currently no filtered terms.'
    else
        output = '<b>Filtered terms:</b>\n• ' ..
            utilities.html_escape(table.concat(group.filter, '\n• '))
    end
    utilities.send_reply(msg, output, 'html')
end

return P
