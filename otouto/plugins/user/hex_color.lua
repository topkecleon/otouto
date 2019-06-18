--[[
    hex_color.lua
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

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('colou?r', true):t('hex', true).table
    self.command = 'color [ffffff]'
    self.doc = [[Returns an image of the given color code. Color codes must be in hexadecimal.
Acceptable code formats:
ABCDEF -> #ABCDEF
F96 -> #FF9966
F5 -> #F5F5F5
F -> #FFFFFF
The preceding hash symbol is optional.]]
    self.url = 'http://www.colorhexa.com/%s.png'
    self.invalid_number_error = 'Invalid number. See ' .. bot.config.cmd_pat .. 'help color'
end

function P:action(bot, msg)
    local input = utilities.get_word(msg.text, 2)
    if input then
        input = input:gsub('#', '')
        input_is_number = tonumber('0x' .. input)
        if input_is_number and (#input <= 3 or #input == 6) then
            local hex
            if #input == 1 then
                hex = input:rep(6)
            elseif #input == 2 then
                hex = input:rep(3)
            elseif #input == 3 then
                hex = ''
                for s in input:gmatch('.') do
                    hex = hex .. s .. s
                end
            elseif #input == 6 then
                hex = input
            end
            bindings.sendPhoto{
                chat_id = msg.chat.id,
                reply_to_message_id = msg.message_id,
                photo = self.url:format(hex),
                caption = '#' .. hex
            }
        else
            utilities.send_reply(msg, self.invalid_number_error)
        end
    else
        utilities.send_reply(msg, self.doc, 'html')
    end
end

return P
