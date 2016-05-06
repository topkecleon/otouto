local reddit = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

reddit.command = 'reddit [r/subreddit | query]'
reddit.doc = [[```
/reddit [r/subreddit | query]
Returns the four (if group) or eight (if private message) top posts for the given subreddit or query, or from the frontpage.
Aliases: /r, /r/[subreddit]
```]]

function reddit:init()
	reddit.triggers = utilities.triggers(self.info.username, {'^/r/'}):t('reddit', true):t('r', true):t('r/', true).table
end

function reddit:action(msg)

	msg.text_lower = msg.text_lower:gsub('/r/', '/r r/')
	local input
	if msg.text_lower:match('^/r/') then
		msg.text_lower = msg.text_lower:gsub('/r/', '/r r/')
		input = utilities.get_word(msg.text_lower, 1)
	else
		input = utilities.input(msg.text_lower)
	end
	local url

	local limit = 4
	if msg.chat.id == msg.from.id then
		limit = 8
	end

	local source
	if input then
		if input:match('^r/.') then
			url = 'http://www.reddit.com/' .. URL.escape(input) .. '/.json?limit=' .. limit
			source = '*/r/' .. input:match('^r/(.+)') .. '*\n'
		else
			url = 'http://www.reddit.com/search.json?q=' .. URL.escape(input) .. '&limit=' .. limit
			source = '*reddit results for* _' .. input .. '_ *:*\n'
		end
	else
		url = 'http://www.reddit.com/.json?limit=' .. limit
		source = '*/r/all*\n'
	end

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if #jdat.data.children == 0 then
		bindings.sendReply(self, msg, self.config.errors.results)
		return
	end

	local output = ''
	for _,v in ipairs(jdat.data.children) do
		local title = v.data.title:gsub('%[', '('):gsub('%]', ')'):gsub('&amp;', '&')
		if title:len() > 48 then
			title = title:sub(1,45) .. '...'
		end
		if v.data.over_18 then
			v.data.is_self = true
		end
		local short_url = 'redd.it/' .. v.data.id
		output = output .. '• [' .. title .. '](' .. short_url .. ')\n'
		if not v.data.is_self then
			output = output .. v.data.url:gsub('_', '\\_') .. '\n'
		end
	end

	output = source .. output

	bindings.sendMessage(self, msg.chat.id, output, true, nil, true)

end

return reddit
