 -- Based on a plugin by matthewhesketh.

local HTTP = require('socket.http')
local HTTPS = require('ssl.https')
local utilities = require('otouto.utilities')

local isup = {}

function isup:init(config)
    isup.triggers = utilities.triggers(self.info.username, config.cmd_pat)
        :t('websitedown', true):t('isitup', true):t('isup', true).table

    isup.doc = config.cmd_pat .. [[isup <url>
Returns the up or down status of a website.]]
    isup.command = 'isup <url>'
end

function isup:action(msg, config)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, isup.doc, 'html')
        return
    end

    local protocol = HTTP
    local url_lower = input:lower()
    if url_lower:match('^https') then
        protocol = HTTPS
    elseif not url_lower:match('^http') then
        input = 'http://' .. input
    end
    local _, code = protocol.request(input)
    code = tonumber(code)
    local output
    if not code or code > 399 then
        output = 'This website is down or nonexistent.'
    else
        output = 'This website is up.'
    end
    utilities.send_reply(msg, output, true)
end

return isup
