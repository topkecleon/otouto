 -- Thanks to @TiagoDanin for writing the original plugin.

local youtube = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

function youtube:init()
	if not self.config.google_api_key then
		print('Missing config value: google_api_key.')
		print('youtube.lua will not be enabled.')
		return
	end

	youtube.triggers = utilities.triggers(self.info.username):t('youtube', true):t('yt', true).table
end

youtube.command = 'youtube <query>'
youtube.doc = [[```
/youtube <query>
Returns the top result from YouTube.
Alias: /yt
```]]

function youtube:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, youtube.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://www.googleapis.com/youtube/v3/search?key=' .. self.config.google_api_key .. '&type=video&part=snippet&maxResults=4&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.pageInfo.totalResults == 0 then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local vid_url = 'https://www.youtube.com/watch?v=' .. jdat.items[1].id.videoId
	local vid_title = jdat.items[1].snippet.title
	vid_title = vid_title:gsub('%(.+%)',''):gsub('%[.+%]','')
	local output = '[' .. vid_title .. '](' .. vid_url .. ')'

	utilities.send_message(self, msg.chat.id, output, false, nil, true)

end

return youtube
