--[[
    hexcolor.lua
    Returns an image of the given color code in hexadecimal format.

    If colorhexa.com ever stops working for any reason, it would be simple to
    generate these images on-the-fly with ImageMagick installed, like so:
        os.execute(string.format(
            'convert -size 128x128 xc:#%s /tmp/%s.png',
            hex,
            hex
        ))
    Or alternatively, use a magic table to produce and store them.
        local colors = {}
        setmetatable(colors, { __index = function(tab, key)
            filename = '/tmp/' .. key .. '.png'
            os.execute('convert -size 128x128 xc:#' .. key .. ' ' .. filename)
            tab[key] = filename
            return filename
        end})

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local hexcolor = {}

function hexcolor:init()
    hexcolor.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('colou?r', true).table
    hexcolor.command = 'color [ffffff]'
    hexcolor.doc = self.config.cmd_pat .. [[color [ffffff]
Returns an image of the given color code. Color codes must be in hexadecimal.
Acceptable code formats:
FFFFFF -> FFFFFF
F96    -> FF9966
F5     -> F5F5F5
F      -> FFFFFF
The preceding hash symbol is optional.]]
    hexcolor.url = 'http://www.colorhexa.com/%s.png'
end

function hexcolor:action(msg)
    local input = utilities.input(msg.text_lower)
    if not input then
        utilities.send_reply(msg, hexcolor.doc, 'html')
        return
    end
    input = input:gsub('#', '')
    if not tonumber('0x'..input) then
        utilities.send_reply(msg, 'Invalid number.')
        return
    end
    local hex
    if #input == 1 then
        hex = input .. input .. input .. input .. input .. input
    elseif #input == 2 then
        hex = input .. input .. input
    elseif #input == 3 then
        hex = ''
        for s in input:gmatch('.') do
            hex = hex .. s .. s
        end
    elseif #input == 6 then
        hex = input
    else
        utilities.send_reply(msg, 'Invalid length.')
        return
    end
    bindings.sendPhoto{
        chat_id = msg.chat.id,
        reply_to_message_id = msg.message_id,
        photo = hexcolor.url:format(hex)
    }
end

return hexcolor
