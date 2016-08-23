local shout = {}

local utilities = require('otouto.utilities')

shout.command = 'shout <text>'
local utf8 = '('..utilities.char.utf_8..'*)'

function shout:init(config)
    shout.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('shout', true).table
    shout.doc = config.cmd_pat .. 'shout <text> \nShouts something. Input may be the replied-to message.'
end

function shout:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, shout.doc, true)
        return
    end

    input = utilities.trim(input)
    input = input:upper()

    local output = ''
    local inc = 0
    local ilen = 0
    for match in input:gmatch(utf8) do
        if ilen < 20 then
            ilen = ilen + 1
            output = output .. match .. ' '
        end
    end
    ilen = 0
    output = output .. '\n'
    for match in input:sub(2):gmatch(utf8) do
        if ilen < 19 then
            local spacing = ''
            for _ = 1, inc do
                spacing = spacing .. '  '
            end
            inc = inc + 1
            ilen = ilen + 1
            output = output .. match .. ' ' .. spacing .. match .. '\n'
        end
    end
    output = '```\n' .. utilities.trim(output) .. '\n```'
    utilities.send_message(msg.chat.id, output, true, false, true)

end

return shout
