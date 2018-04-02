local utilities = require('otouto.utilities')

local P = {}

P.flags = {
    private = 'Removes the link from the public group list and suppresses logs.'
}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('flags?', true):t('listflags').table
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

    --[[
    self.help = {
        {
            command = 'flag [flag]',
            doc = ... ,
            privilege = 3
        },
        {
            command = 'flaglist',
            doc = ... ,
            privilege = 1
        }
    }
    ]]
end

function P:action(bot, msg, group, user)
    local admin = group.data.admin
    local input = utilities.input_from_msg(msg)
    local output

    if user:rank(bot) < 3 then
        output = self:list_flags(admin.flags)

    elseif not input then
        output = self:list_flags(admin.flags)
            .. '\n\nSpecify a flag or flags to toggle.'
    else
        input = input:lower()
        local out = {}
        for flagname in input:gmatch('%g+') do
            local escaped = utilities.html_escape(flagname)
            if self.flags[flagname] then
                if admin.flags[flagname] then
                    admin.flags[flagname] = nil
                    table.insert(out, 'Flag disabled: ' .. escaped .. '.')
                else
                    admin.flags[flagname] = true
                    table.insert(out, 'Flag enabled: ' .. escaped .. '.')
                end
            else
                table.insert(out, 'Not a valid flag name: ' .. escaped .. '.')
            end
        end
        output = table.concat(out, '\n')
    end

    utilities.send_reply(msg, output, 'html')
end

 -- List flags under Enabled and Disabled.
function P:list_flags(local_flags)
    local disabled_flags = {}
    for flag in pairs(self.flags) do
        if not local_flags[flag] then
            disabled_flags[flag] = true
        end
    end
    return string.format(
        '<b>Enabled flags:</b>\n• %s\n<b>Disabled flags:</b>\n• %s',
        table.concat(self:flag_list(local_flags), '\n• '),
        table.concat(self:flag_list(disabled_flags), '\n• ')
    )
end

 -- List flags.
function P:flag_list(local_flags)
    local t = {}
    for flag in pairs(local_flags) do
        table.insert(t, flag .. ': ' .. self.flags[flag])
    end
    return t
end

return P
