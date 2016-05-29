local urbandictionary = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

urbandictionary.command = 'urbandictionary <query>'
urbandictionary.doc = [[```
/urbandictionary <query>
Returns a definition from Urban Dictionary.
Aliases: /ud, /urban
```]]

function urbandictionary:init()
	urbandictionary.triggers = utilities.triggers(self.info.username):t('urbandictionary', true):t('ud', true):t('urban', true).table
end

function urbandictionary:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, urbandictionary.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'http://api.urbandictionary.com/v0/define?term=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.result_type == "no_results" then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local output = '*' .. jdat.list[1].word .. '*\n\n' .. utilities.trim(jdat.list[1].definition)
	if string.len(jdat.list[1].example) > 0 then
		output = output .. '_\n\n' .. utilities.trim(jdat.list[1].example) .. '_'
	end

	output = output:gsub('%[', ''):gsub('%]', '')

	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return urbandictionary
