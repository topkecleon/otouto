 -- You need a Google API key and a Google Custom Search Engine set up to use this, in config.google_api_key and config.google_cse_key, respectively.
 -- You must also sign up for the CSE in the Google Developer Console, and enable image results.

local gImages = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

function gImages:init()
	if not self.config.google_api_key then
		print('Missing config value: google_api_key.')
		print('gImages.lua will not be enabled.')
		return
	elseif not self.config.google_cse_key then
		print('Missing config value: google_cse_key.')
		print('gImages.lua will not be enabled.')
		return
	end

	gImages.triggers = utilities.triggers(self.info.username):t('image', true):t('i', true):t('insfw', true).table
end

gImages.command = 'image <query>'
gImages.doc = [[```
/image <query>
Returns a randomized top result from Google Images. Safe search is enabled by default; use "/insfw" to disable it. NSFW results will not display an image preview.
Alias: /i
```]]

function gImages:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, gImages.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://www.googleapis.com/customsearch/v1?&searchType=image&imgSize=xlarge&alt=json&num=8&start=1&key=' .. self.config.google_api_key .. '&cx=' .. self.config.google_cse_key

	if not string.match(msg.text, '^/i[mage]*nsfw') then
		url = url .. '&safe=high'
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.searchInformation.totalResults == '0' then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local i = math.random(jdat.queries.request[1].count)
	local img_url = jdat.items[i].link
	local img_title = jdat.items[i].title
	local output = '[' .. img_title .. '](' .. img_url .. ')'


	if msg.text:match('nsfw') then
		utilities.send_reply(self, '*NSFW*\n'..msg, output)
	else
		utilities.send_message(self, msg.chat.id, output, false, nil, true)
	end

end

return gImages
