local xkcd = {}

local HTTP = require('socket.http')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

xkcd.command = 'xkcd [i]'

function xkcd:init(config)
	xkcd.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('xkcd', true).table
	xkcd.doc = [[```
]]..config.cmd_pat..[[xkcd [i]
Returns the latest xkcd strip and its alt text. If a number is given, returns that number strip. If "r" is passed in place of a number, returns a random strip.
```]]
end

function xkcd:action(msg, config)

	local jstr, res = HTTP.request('http://xkcd.com/info.0.json')
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end
	local latest = JSON.decode(jstr).num
	local strip_num = latest

	local input = utilities.input(msg.text)
	if input then
		if input == '404' then
			utilities.send_message(self, msg.chat.id, '*404*\nNot found.', false, nil, true)
			return
		elseif tonumber(input) then
			if tonumber(input) > latest then
				strip_num = latest
			else
				strip_num = input
			end
		elseif input == 'r' then
			strip_num = math.random(latest)
		end
	end

	local res_url = 'http://xkcd.com/' .. strip_num .. '/info.0.json'

	jstr, res = HTTP.request(res_url)
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end
	local jdat = JSON.decode(jstr)

	local output = '*' .. jdat.safe_title .. ' (*[' .. jdat.num .. '](' .. jdat.img .. ')*)*\n_' .. jdat.alt:gsub('_', '\\_') .. '_'

	utilities.send_message(self, msg.chat.id, output, false, nil, true)

end

return xkcd
