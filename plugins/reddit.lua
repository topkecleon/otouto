local reddit = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

reddit.command = 'reddit [r/subreddit | query]'
reddit.doc = [[```
/reddit [r/subreddit | query]
Returns the top posts or results for a given subreddit or query. If no argument is given, returns the top posts from r/all. Querying specific subreddits is not supported.
Aliases: /r, /r/subreddit
```]]

function reddit:init()
	reddit.triggers = utilities.triggers(self.info.username, {'^/r/'}):t('reddit', true):t('r', true):t('r/', true).table
end

local format_results = function(posts)
	local output = ''
	for _,v in ipairs(posts) do
		local post = v.data
		local title = post.title:gsub('%[', '('):gsub('%]', ')'):gsub('&amp;', '&')
		if title:len() > 256 then
			title = title:sub(1, 253)
			title = utilities.trim(title) .. '...'
		end
		local short_url = 'redd.it/' .. post.id
		local s = '[' .. title .. '](' .. short_url .. ')'
		if post.domain and not post.is_self and not post.over_18 then
			s = '`[`[' .. post.domain .. '](' .. post.url:gsub('%)', '\\)') .. ')`]` ' .. s
		end
		output = output .. '• ' .. s .. '\n'
	end
	return output
end

reddit.subreddit_url = 'http://www.reddit.com/%s/.json?limit='
reddit.search_url = 'http://www.reddit.com/search.json?q=%s&limit='
reddit.rall_url = 'http://www.reddit.com/.json?limit='

function reddit:action(msg)
	-- Eight results in PM, four results elsewhere.
	local limit = 4
	if msg.chat.type == 'private' then
		limit = 8
	end
	local text = msg.text_lower
	if text:match('^/r/.') then
		-- Normalize input so this hack works easily.
		text = msg.text_lower:gsub('^/r/', '/r r/')
	end
	local input = utilities.input(text)
	local source, url
	if input then
		if input:match('^r/.') then
			input = utilities.get_word(input, 1)
			url = reddit.subreddit_url:format(input) .. limit
			source = '*/' .. utilities.md_escape(input) .. '*\n'
		else
			input = utilities.input(msg.text)
			source = '*Results for* _' .. utilities.md_escape(input) .. '_ *:*\n'
			input = URL.escape(input)
			url = reddit.search_url:format(input) .. limit
		end
	else
		url = reddit.rall_url .. limit
		source = '*/r/all*\n'
	end
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
	else
		local jdat = JSON.decode(jstr)
		if #jdat.data.children == 0 then
			utilities.send_reply(self, msg, self.config.errors.results)
		else
			local output = format_results(jdat.data.children)
			output = source .. output
			utilities.send_message(self, msg.chat.id, output, true, nil, true)
		end
	end
end

return reddit
