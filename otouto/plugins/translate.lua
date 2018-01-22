--[[
    translate.lua
    Returns an attempted translation of input.

    Uses config.lang for the output language.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local translate = {}

function translate:init()
    assert(
        self.config.yandex_key,
        'translate.lua requires a Yandex translate API key from http://tech.yandex.com/keys/get.'
    )

    translate.command = 'translate [text]'
    translate.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('translate', true):t('tl', true).table
    translate.doc = self.config.cmd_pat .. [[translate [text]
Translates input or the replied-to message into the bot's language.]]
    translate.base_url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key=' .. self.config.yandex_key .. '&lang=' .. self.config.lang .. '&text=%s'
end

function translate:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, translate.doc, 'html')
        return
    end

    local url = translate.base_url:format(URL.escape(input))
    local jstr, code = HTTPS.request(url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    if data.code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local output = '<b>Translation:</b>\n"' .. utilities.html_escape(data.text[1]) .. '"'

    utilities.send_reply(msg.reply_to_message or msg, output, 'html')
end

return translate
