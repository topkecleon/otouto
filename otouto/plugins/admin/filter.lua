--[[
    filter.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('filter', true).table
    self.command = 'filter [term]'
    self.doc = "Adds or removes a filter, or lists all filters. Messages containing filtered terms are deleted. \z
        Filters use Lua patterns."
    self.privilege = 3
    self.administration = true
end

function P:action(_bot, msg, group, _user)
    local admin = group.data.admin
    local input = utilities.input(msg.text_lower)
    local output
    if input then
        local idx
        for i = 1, #admin.filter do
            if admin.filter[i] == input then
                idx = i
                break
            end
        end
        if idx then
            table.remove(admin.filter, idx)
            output = 'That term has been removed from the filter.'
        else
            table.insert(admin.filter, input)
            output = 'That term has been added to the filter.'
        end
    elseif #admin.filter == 0 then
        output = 'There are currently no filtered terms.'
    else
        output = '<b>Filtered terms:</b>\n• ' ..
            utilities.html_escape(table.concat(admin.filter, '\n• '))
    end
    utilities.send_reply(msg, output, 'html')
end

return P
