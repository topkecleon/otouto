local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('link').table
    P.command = 'link'
    P.doc = 'Returns the group link. If the group is private, only moderators may use this command and responses will be sent in private.'
    P.internal = true
end

function P:action(msg, group, user)
    local output
    local link = string.format(
        '<a href="%s">%s</a>',
        group.link,
        utilities.html_escape(msg.chat.title)
    )

    -- Links to private groups are mods+ and are only PM'd.
    if group.flags.private then
        if user.rank > 1 then
            if utilities.send_message(msg.from.id, link, true, nil, 'html') then
                output = 'I have sent you the requested information in a private message.'
            else
                output = 'This group is private. The link must be received privately. Please message me privately and re-run the command.'
            end
        else
            output = 'This group is private. Only moderators may retrieve its link.'
        end
    else
        output = link
    end

    utilities.send_message(msg.chat.id, output, true, msg.message_id, 'html')
end

return P
