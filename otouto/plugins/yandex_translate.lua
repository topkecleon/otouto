--[[
    translate.lua
    Returns an attempted translation of input.

    Uses config.lang for the output language.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local https = require('ssl.https')
local url = require('socket.url')
local dkjson = require('dkjson')

local utilities = require('otouto.utilities')

local tl = {}

function tl:init()
    assert(self.config.yandex_key,
        'yandex_translate.lua requires a Yandex translate API key.')

    tl.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('y?translate', true):t('y?tl', true).table
    tl.command = 'ytranslate <text>'
    tl.doc = self.config.cmd_pat .. [[translate [lang]
    <text>
]] .. self.config.cmd_pat .. [[translate [lang] (in reply)
Translates input or the replied-to message into the bot's default language.
In non-reply commands, $text follows a line break after the command and language code.
Translation service provided by Yandex.
Aliases: /ytranslate, /tl, /ytl.]]
 -- "ytl" = "yucky translate"
    tl.url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key='
        .. self.config.yandex_key .. '&lang=%s&text=%s'
end

function tl:action(msg)
    local lang = self.config.lang
    local text = utilities.input(msg.text)

    if msg.reply_to_message and #msg.reply_to_message.text > 0 then
        if text and text:len() == 2 then
            lang = text:lower()
        end
        text = msg.reply_to_message.text

    else
        if text and text:match('^..\n.') then
            lang, text = text:match('^(..)\n(.+)$')
        end
    end

    if not text then
        utilities.send_reply(msg, tl.doc, 'html')
        return
    end

    local result, code = https.request(tl.url:format(lang, url.escape(text)))
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = dkjson.decode(result)
    if data.code ~= 200 then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local output = string.format('<b>%s → %s:</b>\n%s',
        data.lang:match('^..'):upper(),
        lang:upper(),
        utilities.html_escape(data.text[1])
    )
    utilities.send_reply(msg.reply_to_message or msg, output, 'html')
end

return tl
