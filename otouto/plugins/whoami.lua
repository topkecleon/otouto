local whoami = {}

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

whoami.command = 'whoami'

function whoami:init(config)
    whoami.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('who'):t('whoami').table
    whoami.doc = [[
Returns user and chat info for you or the replied-to message.
Alias: ]] .. config.cmd_pat .. 'who'
end

function whoami:action(msg)
    -- Operate on the replied-to message, if it exists.
    msg = msg.reply_to_message or msg
    -- If it's a private conversation, bot is chat, unless bot is from.
    local chat = msg.from.id == msg.chat.id and self.info or msg.chat
    -- Names for the user and group, respectively. HTML-escaped.
    local from_name = utilities.html_escape(
        utilities.build_name(
            msg.from.first_name,
            msg.from.last_name
        )
    )
    local chat_name = utilities.html_escape(
        chat.title
        or utilities.build_name(chat.first_name, chat.last_name)
    )
    -- "Normalize" a group ID so it's not arbitrarily modified by the bot API.
    local chat_id = math.abs(chat.id)
    if chat_id > 1000000000000 then chat_id = chat_id - 1000000000000 end
    -- Do the thing.
    local output = string.format(
        'You are %s <code>[%s]</code>, and you are messaging %s <code>[%s]</code>.',
        msg.from.username and string.format(
            '@%s, also known as <b>%s</b>',
            msg.from.username,
            from_name
        ) or '<b>' .. from_name .. '</b>',
        msg.from.id,
        msg.chat.username and string.format(
            '@%s, also known as <b>%s</b>',
            chat.username,
            chat_name
        ) or '<b>' .. chat_name .. '</b>',
        chat_id
    )
    bindings.sendMessage(self, {
        chat_id = msg.chat.id,
        reply_to_message_id = msg.message_id,
        disable_web_page_preview = true,
        parse_mode = 'HTML',
        text = output
    })
end

return whoami
