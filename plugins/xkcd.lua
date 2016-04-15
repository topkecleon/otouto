local xkcd = {}

local HTTP = require('socket.http')
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

xkcd.command = 'xkcd [query]'
xkcd.doc = [[```
/xkcd [query]
Returns an xkcd strip and its alt text. If there is no query, it will be randomized.
```]]

function xkcd:init()
	xkcd.triggers = utilities.triggers(self.info.username):t('xkcd', true).table
end

function xkcd:action(msg)

	local input = utilities.input(msg.text)

	local jstr, res = HTTP.request('http://xkcd.com/info.0.json')
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local latest = JSON.decode(jstr).num
	local res_url

	if input then
		local url = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=active&q=site%3axkcd%2ecom%20' .. URL.escape(input)
		jstr, res = HTTPS.request(url)
		if res ~= 200 then
			bindings.sendReply(self, msg, self.config.errors.connection)
			return
		end
		local jdat = JSON.decode(jstr)
		if #jdat.responseData.results == 0 then
			bindings.sendReply(self, msg, self.config.errors.results)
			return
		end
		res_url = jdat.responseData.results[1].url .. 'info.0.json'
	else
		res_url = 'http://xkcd.com/' .. math.random(latest) .. '/info.0.json'
	end

	jstr, res = HTTP.request(res_url)
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end
	local jdat = JSON.decode(jstr)

	local output = '[' .. jdat.num .. '](' .. jdat.img .. ')\n' .. jdat.alt

	bindings.sendMessage(self, msg.chat.id, output, false, nil, true)

end

return xkcd
