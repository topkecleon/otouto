--[[
    preview.lua
    Returns a web page preview without text for a given URL.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local utilities = require('otouto.utilities')

local preview = {}

function preview:init()
    preview.command = 'preview <link>'
    preview.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('preview', true).table
    preview.doc = self.config.cmd_pat .. 'preview <link> \nReturns a full-message, "unlinked" preview.'
end

function preview:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, preview.doc, 'html')
        return
    end

    input = utilities.get_word(input, 1)
    if not input:match('^https?://.+') then
        input = 'http://' .. input
    end

    local res = HTTP.request(input)
    if not res then
        utilities.send_reply(msg, 'Please provide a valid link.')
        return
    end

    if res:len() == 0 then
        utilities.send_reply(msg, 'Sorry, the link you provided is not letting us make a preview.')
        return
    end

    -- Invisible zero-width, non-joiner.
    local output = '<a href="' .. input .. '">' .. utilities.char.zwnj .. '</a>'
    utilities.send_message(msg.chat.id, output, false, nil, 'html')

end

return preview
