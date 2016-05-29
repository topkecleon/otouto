 -- Credit to Heitor (tg:Wololo666; gh:heitorPB) for this plugin.

local apod = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local URL = require('socket.url')
local utilities = require('utilities')

apod.command = 'apod [date]'
apod.doc = [[```
/apod [query]
Returns the Astronomy Picture of the Day.
If the query is a date, in the format YYYY-MM-DD, the APOD of that day is returned.
/apodhd [query]
Returns the image in HD, if available.
/apodtext [query]
Returns the explanation of the APOD.
Source: nasa.gov
```]]

function apod:init()
	apod.triggers = utilities.triggers(self.info.username)
		:t('apod', true):t('apodhd', true):t('apodtext', true).table
end

function apod:action(msg)

	if not self.config.nasa_api_key then
		self.config.nasa_api_key = 'DEMO_KEY'
	end

	local input = utilities.input(msg.text)
	local date = '*'
	local disable_page_preview = false

	local url = 'https://api.nasa.gov/planetary/apod?api_key=' .. self.config.nasa_api_key

	if input then
		if input:match('(%d+)%-(%d+)%-(%d+)$') then
			url = url .. '&date=' .. URL.escape(input)
			date = date .. input
		else
			utilities.send_message(self, msg.chat.id, apod.doc, true, msg.message_id, true)
			return
		end
	else
		date = date .. os.date("%F")
	end

	date = date .. '*\n'

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	if jdat.error then
		utilities.send_reply(msg, self.config.errors.results)
		return
	end

	local img_url = jdat.url

	if string.match(msg.text, '^/apodhd*') then
		img_url = jdat.hdurl or jdat.url
	end

	local output = date .. '[' .. jdat.title  .. '](' .. img_url .. ')'

	if string.match(msg.text, '^/apodtext*') then
		output = output .. '\n' .. jdat.explanation
		disable_page_preview = true
	end

	if jdat.copyright then
		output = output .. '\nCopyright: ' .. jdat.copyright
	end

	utilities.send_message(self, msg.chat.id, output, disable_page_preview, nil, true)

end

return apod
