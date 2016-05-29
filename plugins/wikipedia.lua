local wikipedia = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

wikipedia.command = 'wikipedia <query>'
wikipedia.doc = [[```
/wikipedia <query>
Returns an article from Wikipedia.
Aliases: /w, /wiki
```]]

function wikipedia:init()
	wikipedia.triggers = utilities.triggers(self.info.username):t('wikipedia', true):t('wiki', true):t('w', true).table
end

local get_title = function(search)
	for _,v in ipairs(search) do
		if not v.snippet:match('may refer to:') then
			return v.title
		end
	end
	return false
end

function wikipedia:action(msg)

	-- Get the query. If it's not in the message, check the replied-to message.
	-- If those don't exist, send the help text.
	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, wikipedia.doc, true, msg.message_id, true)
			return
		end
	end

	-- This kinda sucks, but whatever.
	input = input:gsub('#', ' sharp')

	-- Disclaimer: These variables will be reused.
	local jstr, res, jdat

	-- All pretty standard from here.
	local search_url = 'https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch='

	jstr, res = HTTPS.request(search_url .. URL.escape(input))
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	jdat = JSON.decode(jstr)
	if jdat.query.searchinfo.totalhits == 0 then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local title = get_title(jdat.query.search)
	if not title then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	end

	local res_url = 'https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exchars=4000&exsectionformat=plain&titles='

	jstr, res = HTTPS.request(res_url .. URL.escape(title))
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local _
	local text = JSON.decode(jstr).query.pages
	_, text = next(text)
	if not text then
		utilities.send_reply(self, msg, self.config.errors.results)
		return
	else
		text = text.extract
	end

	-- Remove needless bits from the article, take only the first paragraph.
	text = text:gsub('</?.->', '')
	local l = text:find('\n')
	if l then
		text = text:sub(1, l-1)
	end

	-- This block can be annoying to read.
	-- We use the initial title to make the url for later use. Then we remove
	-- the extra bits that won't be in the article. We determine whether the
	-- first part of the text is the title, and if so, we embolden that.
	-- Otherwise, we prepend the text with a bold title. Then we append a "Read
	-- More" link.
	local url = 'https://en.wikipedia.org/wiki/' .. URL.escape(title)
	title = title:gsub('%(.+%)', '')
	local output
	if string.match(text:sub(1, title:len()), title) then
		output = '*' .. title .. '*' .. text:sub(title:len()+1)
	else
		output = '*' .. title:gsub('%(.+%)', '') .. '*\n' .. text:gsub('%[.+%]','')
	end
	output = output .. '\n[Read more.](' .. url:gsub('%)', '\\)') .. ')'

	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return wikipedia
