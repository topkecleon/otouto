local PLUGIN = {}

PLUGIN.typing = true -- usually takes a few seconds to load

PLUGIN.doc = [[
	/hackernews
	Returns some top stories from Hacker News. Four in a group or eight in a private message.
]]

PLUGIN.triggers = {
	'^/hackernews',
	'^/hn$'
}

function PLUGIN.action(msg)

	local message = ''
	local jstr = HTTPS.request('https://hacker-news.firebaseio.com/v0/topstories.json')
	local stories = JSON.decode(jstr)

	local limit = 4
	if msg.chat.id == msg.from.id then
		limit = 8
	end

	for i = 1, limit do
		url = 'https://hacker-news.firebaseio.com/v0/item/'..stories[i]..'.json'
		jstr = HTTPS.request(url)
		jdat = JSON.decode(jstr)
		message = message .. jdat.title .. '\n' .. jdat.url .. '\n'
	end

	send_msg(msg, message)

end

return PLUGIN
