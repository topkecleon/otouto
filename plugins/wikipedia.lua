local doc = [[
	/wiki <topic>
	Search Wikipedia for a relevant article and return its summary.
]]

local triggers = {
	'^/wiki',
	'^/w '
}

local action = function(msg)

	local gurl = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&rsz=1&q=site:wikipedia.org%20'
	local wurl = 'http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exchars=4000&exsectionformat=plain&titles='

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, doc)
	end

	local jstr, res = HTTP.request(gurl..URL.escape(input))
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local title = JSON.decode(jstr)
	local url = title.responseData.results[1].url
	title = title.responseData.results[1].titleNoFormatting
	title = title:gsub(' %- Wikipedia, the free encyclopedia', '')

	jstr, res = HTTPS.request(wurl..URL.escape(title))
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local text = JSON.decode(jstr).query.pages

	for k,v in pairs(text) do
		text = v.extract
		break -- Seriously, there's probably a way more elegant solution.
	end

	if not text then
		return send_msg(msg, config.locale.errors.results)
	end

	--[[ Uncomment this block for more than one-paragraph summaries.
	local l = text:find('<h2>')
	if l then
		text = text:sub(1, l-2)
	end
	]]--

	text = text:gsub('</?.->', '')

	local l = text:find('\n') -- Comment this block for more than one-paragraph summaries.
	if l then
		text = text:sub(1, l-1)
	end

	text = text .. '\n' .. url

	send_msg(msg, text)

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	typing = true
}
