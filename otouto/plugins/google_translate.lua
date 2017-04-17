--[[
    google_translate.lua
    A plugin for the Google translate API.

    Uses config.lang for the output language, unless specified.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local https = require('ssl.https')
local url = require('socket.url')
local dkjson = require('dkjson')

local utilities = require('otouto.utilities')

local tl = {}

function tl:init()
    assert(self.config.google_api_key,
        'google_translate.lua requires a Google API key.')

    tl.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('g?translate', true):t('g?tl', true).table
    tl.command = 'gtranslate <text>'
    tl.doc = self.config.cmd_pat .. [[translate [lang]
    <text>
]] .. self.config.cmd_pat .. [[translate [lang] (in reply)
Translates input or the replied-to message into the bot's default language.
In non-reply commands, $text follows a line break after the command and language code.
Translation service provided by Google.
Aliases: /gtranslate, /tl, /gtl.]]
 -- "gtl" = "good translate"
    tl.url = 'https://translation.googleapis.com/language/translate/v2?key=' ..
        self.config.google_api_key .. '&format=text&target=%s&q=%s'
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
    if not data.data.translations[1] then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local output = string.format('<b>%s → %s:</b>\n%s',
        data.data.translations[1].detectedSourceLanguage:upper(),
        lang:upper(),
        utilities.html_escape(data.data.translations[1].translatedText)
    )
    utilities.send_reply(msg.reply_to_message or msg, output, 'html')
end

return tl
