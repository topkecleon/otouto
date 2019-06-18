--[[
    full_width.lua
    otouto plugin to convert Latin text to Latin full-width text.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('full_?width', true).table
    self.command = 'fullwidth <text>'
    self.doc = 'Returns ａｅｓｔｈｅｔｉｃ text.'
end

function P:action(bot, msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, self.doc, 'html')
        return
    end
    -- Piece together the output by iterating through every character and
    -- changing Latin characters to their full-width counterparts. Characters
    -- which are not in the "Basic Latin" set will be ignored.
    -- Error handling to check whether or not a given
    -- character is in the basic latin set.
    local output = {}

    for char in input:gmatch('.') do
        local succ, code = pcall(function() return utf8.codepoint(char) end)
        -- Full-width codepoints are 65248 higher than their basic counterparts.
        if succ and code >= 33 and code <= 126 then
            table.insert(output, utf8.char(code+65248))
        else
            table.insert(output, char)
        end
    end

    utilities.send_reply(msg, table.concat(output))
end

return P

