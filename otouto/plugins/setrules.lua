 -- all (default), add, change, delete, clear

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('setrules?', true):t('changerules?', true)
        :t('addrules?', true):t('delrules?', true).table
    P.command = 'setrules <subcommand>'
    P.doc = [[
change [i]
    Changes an existing rule or rules, starting at $i. If $i is unspecified, all rules will be overwritten.
    Alias: /changerule

add [i]
    Adds a new rule or rules, inserted starting at $i. If $i is unspecified, the new rule or rules will be added to the end of the list.
    Alias: /addrule

del [i]
    Deletes a rule. If $i is unspecified, all rules will be deleted.
    Alias: /delrule

Examples:
• Set all the rules for a group.
    /changerules
    First rule.
    Second rule.
    ...

• Change rule 4.
    /changerule 4
    Changed fourth rule.
    [Changed fifth rule.]

• Add a rule or rules between 2 and 3.
    /addrule 3
    New third rule.
    [New fourth rule.]
    ]]

    P.privilege = 3
    P.interior = true
end

function P:action(msg, group)
    local subc, idx

    -- "/changerule ..." -> "/setrules change ..."
    local c = '^' .. self.config.cmd_pat
    if msg.text_lower:match(c..'changerule') then
        subc = 'change'
        idx = msg.text_lower:match(c..'changerules?%s+(%d+)')

    elseif msg.text_lower:match(c..'addrule') then
        subc = 'add'
        idx = msg.text_lower:match(c..'addrules?%s+(%d+)')

    elseif msg.text_lower:match(c..'delrule') then
        subc = 'del'
        idx = msg.text_lower:match(c..'delrules?%s+(%d+)')
    else
        subc, idx = msg.text_lower:match(c..'setrules?%s+(%a+)%s*(%d*)')
    end

    local nrules = msg.text:match('^.-\n+(.+)$') or msg.reply_to_message and
        msg.reply_to_message.text
    local new_rules = {}
    if nrules then
        for s in string.gmatch(nrules..'\n', '(.-)\n') do
            table.insert(new_rules, s)
        end
    end

    local output
    if P.subcommands[subc] then
        output = P.subcommands[subc](group, new_rules, tonumber(idx))
    else
        output = 'Invalid subcommand. See /help setrules.'
    end

    utilities.send_reply(msg, output, 'html')
end

P.subcommands = {}

function P.subcommands.change(group, new_rules, idx)
    if #new_rules == 0 then
        return 'Please specify the new rule or rules.'

    elseif not idx then -- /setrules
        group.rules = new_rules
        local output = '<b>Rules for ' .. utilities.html_escape(group.name) ..
            ':</b>'
        for i, rule in ipairs(group.rules) do
            output = output .. '\n<b>' .. i .. '.</b> ' .. rule
        end
        return output

    elseif idx < 1 then
        return 'Invalid index.'

    elseif idx > #group.rules then
        return P.subcommands.add(group, new_rules, idx)

    else -- /changerule i
        local output = ''
        for i = 1, #new_rules do
            group.rules[idx+i-1] = new_rules[i]
            output = output .. '\n<b>' .. idx+i-1 .. '.</b> ' .. new_rules[i]
        end
        return output
    end
end

function P.subcommands.add(group, new_rules, idx)
    if #new_rules == 0 then
        return 'Please specify the new rule or rules.'

    elseif not idx or idx > #group.rules then -- /addrule
        local output = ''
        for i = 1, #new_rules do
            table.insert(group.rules, new_rules[i])
            output = output .. '\n<b>' .. #group.rules .. '.</b> ' .. new_rules[i]
        end
        return output

    elseif idx < 1 then
        return 'Invalid index.'

    else -- /addrule i
        local output = ''
        for i = 1, #new_rules do
            table.insert(group.rules, idx+i-1, new_rules[i])
            output = output .. '\n<b>' .. idx+i-1 .. '.</b> ' .. new_rules[i]
        end
        return output
    end
end

function P.subcommands.del(group, _, idx)
    if not idx then -- /setrules --
        group.rules = {}
        return 'The rules have been deleted.'

    elseif idx > #group.rules or idx < 0 then
        return 'Invalid index.'

    else -- /changerule i --
        table.remove(group.rules, idx)
        return 'Rule ' .. idx .. ' has been deleted.'
    end
end

return P
