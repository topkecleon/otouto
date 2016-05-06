local wikipedia = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')
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

function wikipedia:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			bindings.sendMessage(self, msg.chat.id, wikipedia.doc, true, msg.message_id, true)
			return
		end
	end

	local gurl = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&rsz=1&q=site:wikipedia.org%20'
	local wurl = 'https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exchars=4000&exsectionformat=plain&titles='

	local jstr, res = HTTPS.request(gurl .. URL.escape(input))
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.responseData then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end
	if not jdat.responseData.results[1] then
		bindings.sendReply(self, msg, self.config.errors.results)
		return
	end

	local url = jdat.responseData.results[1].unescapedUrl
	local title = jdat.responseData.results[1].titleNoFormatting:gsub(' %- Wikipedia, the free encyclopedia', '')

	-- 'https://en.wikipedia.org/wiki/':len() == 30
	jstr, res = HTTPS.request(wurl .. url:sub(31))
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.error.connection)
		return
	end

	local _
	local text = JSON.decode(jstr).query.pages
	_, text = next(text)
	if not text then
		bindings.sendReply(self, msg, self.config.errors.results)
		return
	else
		text = text.extract
	end

	text = text:gsub('</?.->', '')
	local l = text:find('\n')
	if l then
		text = text:sub(1, l-1)
	end

	title = title:gsub('%(.+%)', '')
	local esctitle = title:gsub("[%^$()%%.%[%]*+%-?]","%%%1")
	local output = text:gsub('%[.+%]',''):gsub(esctitle, '*%1*') .. '\n'
	if url:find('%(') then
		output = output .. url:gsub('_', '\\_')
	else
		output = output .. '[Read more.](' .. url .. ')'
	end

	bindings.sendMessage(self, msg.chat.id, output, true, nil, true)

end

return wikipedia
