local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('reddit.COMMAND') .. ' [' .. I18N('reddit.ARG_SUBREDDIT') .. ' | ' .. I18N('ARG_QUERY') .. ']\n' .. I18N('reddit.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('reddit.COMMAND'),
	'^' .. config.COMMAND_START .. 'r$',
	'^' .. config.COMMAND_START .. 'r '
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
				return send_msg(msg, I18N('CONNECTION_ERROR'))
			end
			jdat = JSON.decode(jstr)
			if #jdat.data.children == 0 then
				return send_msg(msg, I18N('reddit.SUBREDDIT_NOT_FOUND'))
			end

		else

			local url = 'http://www.reddit.com/search.json?q=' .. URL.escape(input)
			local jstr, res = HTTP.request(url)
			if res ~= 200 then
				return send_msg(msg, I18N('CONNECTION_ERROR'))
			end
			jdat = JSON.decode(jstr)
			if #jdat.data.children == 0 then
				return send_msg(msg, I18N('NO_RESULTS_FOUND'))
			end

		end

	else

		url = 'https://www.reddit.com/.json'
		local jstr, res = HTTP.request(url)
		if res ~= 200 then
			return send_msg(msg, I18N('CONNECTION_ERROR'))
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
