 -- You need a Google API key and a Google Custom Search Engine set up to use this, in config.google_api_key and config.google_cse_key, respectively.
 -- You must also sign up for the CSE in the Google Developer Console, and enable image results.

local gImages = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

function gImages:init(config)
	if not config.google_api_key then
		print('Missing config value: google_api_key.')
		print('gImages.lua will not be enabled.')
		return
	elseif not config.google_cse_key then
		print('Missing config value: google_cse_key.')
		print('gImages.lua will not be enabled.')
		return
	end

	gImages.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('image', true):t('i', true):t('insfw', true).table
	gImages.doc = [[```
]]..config.cmd_pat..[[image <query>
Returns a randomized top result from Google Images. Safe search is enabled by default; use "]]..config.cmd_pat..[[insfw" to disable it. NSFW results will not display an image preview.
Alias: ]]..config.cmd_pat..[[i
```]]
end

gImages.command = 'image <query>'

function gImages:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, gImages.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://www.googleapis.com/customsearch/v1?&searchType=image&imgSize=xlarge&alt=json&num=8&start=1&key=' .. config.google_api_key .. '&cx=' .. config.google_cse_key

	if not string.match(msg.text, '^'..config.cmd_pat..'i[mage]*nsfw') then
		url = url .. '&safe=high'
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.searchInformation.totalResults == '0' then
		utilities.send_reply(self, msg, config.errors.results)
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
