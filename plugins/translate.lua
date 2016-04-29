local translate = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

translate.command = 'translate [text]'
translate.doc = [[```
/translate [text]
Translates input or the replied-to message into the bot's language.
```]]

function translate:init()
	translate.triggers = utilities.triggers(self.info.username):t('translate', true):t('tl', true).table
end

function translate:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			bindings.sendMessage(self, msg.chat.id, translate.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key=' .. self.config.yandex_key .. '&lang=' .. self.config.lang .. '&text=' .. URL.escape(input)

	local str, res = HTTPS.request(url)
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(str)
	if jdat.code ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local output = jdat.text[1]
	output = '*Translation:*\n"' .. utilities.md_escape(output) .. '"'

	bindings.sendReply(self, msg.reply_to_message or msg, output)

end

return translate
