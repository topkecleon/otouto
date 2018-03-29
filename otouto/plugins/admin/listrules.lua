local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('rules?', true).table
    self.command = 'rules [i]'
    self.doc = 'Returns the list of rules, or the specified rule.'
    self.administration = true
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    local input = tonumber(utilities.get_word(msg.text, 2))
    local output
    if #admin.rules == 0 then
        output = 'No rules have been set for this group.'
    elseif input and admin.rules[input] then
        output = '<b>' .. input .. '.</b> ' .. admin.rules[input]
    else
        output = '<b>Rules for ' ..utilities.html_escape(admin.name).. ':</b>'
        for i, rule in ipairs(admin.rules) do
            output = output .. '\n<b>' .. i .. '</b>. ' .. rule
        end

        if next(admin.flags) ~= nil then
            output = output .. '\n\n<b>Flags:</b>'
            for flag in pairs(admin.flags) do
                output = output .. '\n• ' .. flag .. ': ' ..
                    bot.named_plugins['admin.flags'].flags[flag]
            end
        end
    end
    utilities.send_reply(msg, output, 'html')
end

return P
