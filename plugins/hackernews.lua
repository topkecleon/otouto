local hackernews = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

hackernews.command = 'hackernews'
hackernews.doc = [[```
Returns four (if group) or eight (if private message) top stories from Hacker News.
Alias: /hn
```]]

function hackernews:init()
	hackernews.triggers = utilities.triggers(self.info.username):t('hackernews', true):t('hn', true).table
end

function hackernews:action(msg)

	bindings.sendChatAction(self, msg.chat.id, 'typing')

	local jstr, res = HTTPS.request('https://hacker-news.firebaseio.com/v0/topstories.json')
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	local res_count = 4
	if msg.chat.id == msg.from.id then
		res_count = 8
	end

	local output = '*Hacker News:*\n'
	for i = 1, res_count do
		local res_url = 'https://hacker-news.firebaseio.com/v0/item/' .. jdat[i] .. '.json'
		jstr, res = HTTPS.request(res_url)
		if res ~= 200 then
			bindings.sendReply(self, msg, self.config.errors.connection)
			return
		end
		local res_jdat = JSON.decode(jstr)
		local title = res_jdat.title:gsub('%[.+%]', ''):gsub('%(.+%)', ''):gsub('&amp;', '&')
		if title:len() > 48 then
			title = title:sub(1, 45) .. '...'
		end
		local url = res_jdat.url
		if not url then
			bindings.sendReply(self, msg, self.config.errors.connection)
			return
		end
		if url:find('%(') then
			output = output .. '• ' .. title .. '\n' .. url:gsub('_', '\\_') .. '\n'
		else
			output = output .. '• [' .. title .. '](' .. url .. ')\n'
		end

	end

	bindings.sendMessage(self, msg.chat.id, output, true, nil, true)

end

return hackernews
