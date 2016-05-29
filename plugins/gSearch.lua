local gSearch = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

gSearch.command = 'google <query>'
gSearch.doc = [[```
/google <query>
Returns four (if group) or eight (if private message) results from Google. Safe search is enabled by default, use "/gnsfw" to disable it.
Alias: /g
```]]

function gSearch:init()
	gSearch.triggers = utilities.triggers(self.info.username):t('g', true):t('google', true):t('gnsfw', true).table
end

function gSearch:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, gSearch.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0'

	if msg.from.id == msg.chat.id then
		url = url .. '&rsz=8'
	else
		url = url .. '&rsz=4'
	end

	if not string.match(msg.text, '^/g[oogle]*nsfw') then
		url = url .. '&safe=active'
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.responseData then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end
	if not jdat.responseData.results[1] then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local output = '*Google results for* _' .. input .. '_ *:*\n'
	for i,_ in ipairs(jdat.responseData.results) do
		local title = jdat.responseData.results[i].titleNoFormatting:gsub('%[.+%]', ''):gsub('&amp;', '&')
--[[
		if title:len() > 48 then
			title = title:sub(1, 45) .. '...'
		end
]]--
		local u = jdat.responseData.results[i].unescapedUrl
		if u:find('%)') then
			output = output .. '• ' .. title .. '\n' .. u:gsub('_', '\\_') .. '\n'
		else
			output = output .. '• [' .. title .. '](' .. u .. ')\n'
		end
	end

	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return gSearch
