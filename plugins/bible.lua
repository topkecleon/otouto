local bible = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local bindings = require('bindings')
local utilities = require('utilities')

function bible:init()
	if not self.config.biblia_api_key then
		print('Missing config value: biblia_api_key.')
		print('bible.lua will not be enabled.')
		return
	end

	bible.triggers = utilities.triggers(self.info.username):t('bible', true):t('b', true).table
end

bible.command = 'bible <reference>'
bible.doc = [[```
/bible <reference>
Returns a verse from the American Standard Version of the Bible, or an apocryphal verse from the King James Version. Results from biblia.com.
Alias: /b
```]]

function bible:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		bindings.sendMessage(self, msg.chat.id, bible.doc, true, msg.message_id, true)
		return
	end

	local url = 'http://api.biblia.com/v1/bible/content/ASV.txt?key=' .. self.config.biblia_api_key .. '&passage=' .. URL.escape(input)

	local message, res = HTTP.request(url)

	if not message or res ~= 200 or message:len() == 0 then
		url = 'http://api.biblia.com/v1/bible/content/KJVAPOC.txt?key=' .. self.config.biblia_api_key .. '&passage=' .. URL.escape(input)
		message, res = HTTP.request(url)
	end

	if not message or res ~= 200  or message:len() == 0 then
		message = self.config.errors.results
	end

	if message:len() > 4000 then
		message = 'The text is too long to post here. Try being more specific.'
	end

	bindings.sendReply(self, msg, message)

end

return bible
