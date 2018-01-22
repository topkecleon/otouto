--[[
    xkcd.lua
    Returns the latest strip, a random strip, or a numbered strip from xkcd.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local xkcd = {}

function xkcd:init()
    xkcd.command = 'xkcd [i]'
    xkcd.base_url = 'https://xkcd.com/info.0.json'
    xkcd.strip_url = 'https://xkcd.com/%s/info.0.json'
    xkcd.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('xkcd', true).table
    xkcd.doc = self.config.cmd_pat .. [[xkcd [i]
Returns the latest xkcd strip and its alt text. If a number is given, returns that number strip. If "r" is passed in place of a number, returns a random strip.]]
    local jstr = HTTPS.request(xkcd.base_url)
    if jstr then
        local data = JSON.decode(jstr)
        if data then
            xkcd.latest = data.num
        end
    end
    xkcd.latest = xkcd.latest or 1700
end

function xkcd:action(msg)
    local input = utilities.get_word(msg.text, 2)
    if input == 'r' then
        input = math.random(xkcd.latest)
    elseif tonumber(input) then
        input = tonumber(input)
    else
        input = xkcd.latest
    end
    local url = xkcd.strip_url:format(input)
    local jstr, code = HTTPS.request(url)
    if code == 404 then
        utilities.send_reply(msg, self.config.errors.results)
    elseif code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
    else
        local data = JSON.decode(jstr)
        local output = string.format(
            '<b>%s</b> (<a href="%s">%s</a>)\n<i>%s</i>',
            utilities.html_escape(utilities.fix_utf8(data.safe_title)),
            utilities.html_escape(data.img),
            data.num,
            utilities.html_escape(utilities.fix_utf8(data.alt))
        )
        utilities.send_message(msg.chat.id, output, false, nil, 'html')
    end
end

return xkcd
