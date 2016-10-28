--[[
    patterns.lua
    Sed-like substitution using Lua patterns. Ignores commands with no reply-to
    message.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local patterns = {}

local utilities = require('otouto.utilities')

function patterns:init()
    patterns.command = 's/<pattern>/<substitution>'
    patterns.help_word = 'patterns'
    patterns.doc = [[s/<pattern>/<substitution>
Replace all matches for the given pattern.
Uses Lua patterns.]]
    patterns.triggers = { self.config.cmd_pat .. '?s/.-/.-$' }
end

function patterns:action(msg)
    if not msg.reply_to_message then return true end
    local output = msg.reply_to_message.text
    if msg.reply_to_message.from.id == self.info.id then
        output = output:match('^Did you mean:\n"(.+)"$') or output
    end
    local m1, m2 = msg.text:match('^/?s/(.-)/(.-)/?$')
    if not m2 then return true end
    local res
    res, output = pcall(
        function()
            return output:gsub(m1, m2)
        end
    )
    if res == false then
        utilities.send_reply(msg, 'Malformed pattern!')
    else
        output = utilities.trim(output:sub(1, 4000))
        output = '<b>Did you mean:</b>\n"' .. utilities.html_escape(output) .. '"'
        utilities.send_reply(msg.reply_to_message, output, 'html')
    end
end

return patterns
