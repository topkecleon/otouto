local command = 'wikipedia <query>'
local doc = [[```
/wikipedia <query>
Returns an article from Wikipedia.
Aliases: /w, /wiki
```]]

local triggers = {
	'^/wikipedia[@'..bot.username..']*',
	'^/wiki[@'..bot.username..']*',
	'^/w[@'..bot.username..']*$',
	'^/w[@'..bot.username..']* '
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
			return
		end
	end

	local gurl = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&rsz=1&q=site:wikipedia.org%20'
	local wurl = 'https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exchars=4000&exsectionformat=plain&titles='

	local jstr, res = HTTPS.request(gurl .. URL.escape(input))
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.responseData then
		sendReply(msg, config.errors.connection)
		return
	end
	if not jdat.responseData.results[1] then
		sendReply(msg, config.errors.results)
		return
	end

	local url = jdat.responseData.results[1].unescapedUrl
	local title = jdat.responseData.results[1].titleNoFormatting:gsub(' %- Wikipedia, the free encyclopedia', '')

	-- 'https://en.wikipedia.org/wiki/':len() == 30
	jstr, res = HTTPS.request(wurl .. url:sub(31))
	if res ~= 200 then
		sendReply(msg, config.error.connection)
		return
	end

	local text = JSON.decode(jstr).query.pages
	for k,v in pairs(text) do
		text = v.extract
		break -- Seriously, there's probably a way more elegant solution.
	end
	if not text then
		sendReply(msg, config.errors.results)
		return
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

	sendMessage(msg.chat.id, output, true, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
