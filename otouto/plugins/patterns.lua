--[[
    patterns.lua
    Sed-like substitution using Lua patterns. Ignores commands with no reply-to
    message.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local patterns = {}

local utilities = require('otouto.utilities')

function patterns:init()
    patterns.command = 'gsub/<pattern>/<substitution>'
    patterns.help_word = 'patterns'
    patterns.doc = [[gsub/<pattern>/<substitution>
Replace all matches for the given pattern.
Uses Lua patterns.]]
    patterns.triggers = { self.config.cmd_pat .. '?gsub/.-/.-$' }
end

function patterns:action(msg)
    -- Return if there is no message to change.
    if not msg.reply_to_message then return true end

    local input = msg.reply_to_message.text
    if msg.reply_to_message.from.id == self.info.id then
        input = input:match('^Did you mean:\n"(.+)"$') or input
    end

    local pattern, substitution = -- Assuming config.cmd_pat is only one char.
        msg.text:match('^' .. self.config.cmd_pat .. '?gsub/(.-)/(.-)/?$')

    -- Return if there is no pattern or substitution.
    if not substitution then return true end

    local success, result = pcall(
        function() return { input:gsub(pattern, substitution) } end
    )

    if success == false then -- Error occurred; probably a bad pattern.
        utilities.send_reply(msg, 'Malformed pattern!')
    elseif result[2] == 0 then -- No substitutions occurred.
        return
    else -- Success.
        local output = utilities.trim(result[1]:sub(1, 4000))
        output = '<b>Did you mean:</b>\n"' .. utilities.html_escape(output) .. '"'
        utilities.send_reply(msg.reply_to_message, output, 'html')
    end
end

return patterns
