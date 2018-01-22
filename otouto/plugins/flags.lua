local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

P.flags = {
    private = 'The group is not publicly listed.'
}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('flags?', true).table
    P.command = 'flags [flag]'
    P.doc = 'Returns a list of flags, or toggles the specified flag.'
    internal = true
    privilege = 3
end

function P:action(msg, group)
    local input = utilities.input_from_msg(msg)
    local output = {}

    if input then
        for word in input:gmatch('%g+') do
            word_lwr = word:lower()
            if P.flags[word_lwr] then
                if group.flags[word_lwr] then
                    group.flags[word_lwr] = nil
                    table.insert(output, word .. ' has been disabled.')
                else
                    group.flags[word_lwr] = true
                    table.insert(output, word .. ' has been enabled.')
                end
            else
                table.insert(output, 'Invalid flag (' ..
                    utilities.html_escape(word) .. ').')
            end
        end

    else
        table.insert(output, '<b>Flags:</b>')
        for name, desc in pairs(P.flags) do
            table.insert(output, string.format('%s <b>%s</b>\n%s',
                group.flags[name] and '✔️' or '❌',
                name,
                desc
            ))
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
