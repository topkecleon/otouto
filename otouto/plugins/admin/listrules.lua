local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('rules?', true):t('listrules').table
    self.command = 'rules [i]'
    self.doc = 'Returns the list of rules, or the specified rule.'
    self.administration = true
end

function P:action(_bot, msg, group)
    local admin = group.data.admin
    local input = tonumber(utilities.get_word(msg.text, 2))
    local output
    if #admin.rules == 0 then
        output = 'No rules have been set for this group.'
    elseif input and admin.rules[input] then
        output = self.rule_list(admin.rules)[input]
    else
        output = '<b>Rules for ' ..utilities.html_escape(msg.chat.title).. ':</b>\n'
            .. table.concat(self.rule_list(admin.rules), '\n')
    end
    utilities.send_reply(msg, output, 'html')
end

function P.rule_list(rules)
    local t = {}
    for i, rule in ipairs(rules) do
        table.insert(t, '<b>' .. i .. '.</b> ' .. rule)
    end
    return t
end

return P
