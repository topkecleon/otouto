local bible = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local utilities = require('otouto.utilities')

function bible:init(config)
	if not config.biblia_api_key then
		print('Missing config value: biblia_api_key.')
		print('bible.lua will not be enabled.')
		return
	end

	bible.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('bible', true):t('b', true).table
	bible.doc = [[```
]]..config.cmd_pat..[[bible <reference>
Returns a verse from the American Standard Version of the Bible, or an apocryphal verse from the King James Version. Results from biblia.com.
Alias: ]]..config.cmd_pat..[[b
```]]
end

bible.command = 'bible <reference>'

function bible:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		utilities.send_message(self, msg.chat.id, bible.doc, true, msg.message_id, true)
		return
	end

	local url = 'http://api.biblia.com/v1/bible/content/ASV.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)

	local output, res = HTTP.request(url)

	if not output or res ~= 200 or output:len() == 0 then
		url = 'http://api.biblia.com/v1/bible/content/KJVAPOC.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)
		output, res = HTTP.request(url)
	end

	if not output or res ~= 200  or output:len() == 0 then
		output = config.errors.results
	end

	if output:len() > 4000 then
		output = 'The text is too long to post here. Try being more specific.'
	end

	utilities.send_reply(self, msg, output)

end

return bible
