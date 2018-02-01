local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('rules?', true).table
    P.command = 'rules [i]'
    P.doc = 'Returns the list of rules, or the specified rule.'
    P.internal = true
end

function P:action(msg, group)
    local input = tonumber(utilities.get_word(msg.text, 2))
    local output
    if #group.rules == 0 then
        output = 'No rules have been set for this group.'
    elseif input and group.rules[input] then
        output = '<b>' .. input .. '.</b> ' .. group.rules[input]
    else
        output = '<b>Rules for ' ..utilities.html_escape(group.name).. ':</b>'
        for i, rule in ipairs(group.rules) do
            output = output .. '\n<b>' .. i .. '</b>. ' .. rule
        end

        if next(group.flags) ~= nil then
            output = output .. '\n\n<b>Flags:</b>'
            for flag in pairs(group.flags) do
                output = output .. '\n• ' .. flag .. ': ' ..
                    self.named_plugins.flags.flags[flag]
            end
        end
    end
    utilities.send_reply(msg, output, 'html')
end

return P
