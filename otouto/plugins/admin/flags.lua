local utilities = require('otouto.utilities')

local P = {}

P.flags = {
    private = 'Removes the link from the public group list and suppresses logs.'
}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('flags?', true).table
    self.command = 'flags [flag]'
    self.help_word = 'flags?'
    local default_flags = {}
    for flag in pairs(bot.config.administration.flags) do
        table.insert(default_flags, flag)
    end
    self.doc = "\z
Usage: " .. bot.config.cmd_pat .. "flags [flag] \
Returns a list of flags, or toggles the specified flag. \
Flags are administrative policies at the disposal of the governor. Most \z
provide optional automoderation (see /help antilink). The private flag \z
removes a group's link from the public list and makes it only available to \z
moderators and greater. \z
The following flags are enabled by default:\n" ..
table.concat(default_flags, '\n•')
    self.administration = true
    self.privilege = 3
end

function P:action(_bot, msg, group)
    local input = utilities.input_from_msg(msg)
    local output = {}

    if input then
        for word in input:gmatch('%g+') do
            local word_lwr = word:lower()
            if self.flags[word_lwr] then
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
        for name, desc in pairs(self.flags) do
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
