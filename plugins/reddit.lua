local PLUGIN = {}

PLUGIN.doc = [[
	/reddit [r/subreddit | query]
	This command returns top results for a given query or subreddit. NSFW posts are marked as such.
]]

PLUGIN.triggers = {
	'^/reddit',
	'^/r$',
	'^/r '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	local jdat = {}
	local message = ''

	if input then

		if string.match(input, '^r/') then

			local url = 'http://www.reddit.com/' .. first_word(input) .. '/.json'
			local jstr, res = HTTP.request(url)
			if res ~= 200 then
				return send_msg(msg, config.locale.errors.connection)
			end
			jdat = JSON.decode(jstr)
			if #jdat.data.children == 0 then
				return send_msg(msg, config.locale.errors.results)
			end

		else

			local url = 'http://www.reddit.com/search.json?q=' .. URL.escape(input)
			local jstr, res = HTTP.request(url)
			if res ~= 200 then
				return send_msg(msg, config.locale.errors.connection)
			end
			jdat = JSON.decode(jstr)
			if #jdat.data.children == 0 then
				return send_msg(msg, config.locale.errors.results)
			end

		end

	else

		url = 'https://www.reddit.com/.json'
		local jstr, res = HTTP.request(url)
		if res ~= 200 then
			return send_msg(msg, config.locale.errors.connection)
		end
		jdat = JSON.decode(jstr)

	end

	local limit = 4
	if #jdat.data.children < limit then
		limit = #jdat.data.children
	end

	for i = 1, limit do

		if jdat.data.children[i].data.over_18 then
			message = message .. '[NSFW] '
		end

		url = '\n'
		if not jdat.data.children[i].data.is_self then
			url = '\n' .. jdat.data.children[i].data.url .. '\n'
		end

		local short_url = '[redd.it/' .. jdat.data.children[i].data.id .. '] '
		message = message .. short_url .. jdat.data.children[i].data.title .. url

	end

	send_msg(msg, message)

end

return PLUGIN
