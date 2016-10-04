local echo = {}

local utilities = require('otouto.utilities')

echo.command = 'echo <text>'

function echo:init(config)
    echo.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('echo', true).table
    echo.doc = config.cmd_pat .. 'echo <text> \nRepeats a string of text.'
end

function echo:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_message(msg.chat.id, echo.doc, true, msg.message_id, 'html')
    else
        local output
        if msg.chat.type == 'supergroup' then
            output = '<b>Echo:</b>\n"' .. utilities.html_escape(input) .. '"'
        else
            output = utilities.html_escape(utilities.char.zwnj..input)
        end
        utilities.send_message(msg.chat.id, output, true, nil, 'html')
    end
end

return echo
