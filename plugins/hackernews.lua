local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('hackernews.COMMAND') .. '\n' .. I18N('hackernews.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('hackernews.COMMAND'),
	'^' .. config.COMMAND_START .. 'hn$'
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
