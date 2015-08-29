local PLUGIN = {}

PLUGIN.doc = [[
	/lastfm [username]
	Get current- or last-played track data from last.fm. If a username is specified, it will return info for that username rather than your own.
	"/fmset username" will configure your last.fm username.
]]

PLUGIN.triggers = {
	'^/lastfm',
	'^/np$',
	'^/fm$',
	'^/fmset'
}

function PLUGIN.action(msg)

	if msg.text:match('^/fmset') then

		local input = get_input(msg.text)
		if not input then
			return send_msg(msg, PLUGIN.doc)
		end

		local data = load_data('lastfm.json')
		local id = tostring(msg.from.id)

		data[id] = input

		save_data('lastfm.json', data)

		send_msg(msg, 'Your last.fm username has been set to ' .. input .. '.')

		return

	end

	local base_url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. config.lastfm_api_key .. '&user='

	local input = get_input(msg.text)
	if not input then
		local data = load_data('lastfm.json')
		if data[tostring(msg.from.id)] then
			input = data[tostring(msg.from.id)]
		elseif msg.from.username then
			input = msg.from.username
		else
			return send_msg(msg, 'Please provide a valid last.fm username.\nYou can set yours with /fmset.')
		end
	end

	local jstr, res = HTTP.request(base_url..input)

	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)

	if jdat.error then
		return send_msg(msg, 'Please provide a valid last.fm username.\nYou can set yours with /fmset.')
	end

	if not jdat.recenttracks.track then
		return send_msg(msg, 'No history for that user.')
	end

	local jdat = jdat.recenttracks.track[1] or jdat.recenttracks.track

	local message = '🎵  ' .. msg.from.first_name .. ' last listened to:\n'
	if jdat['@attr'] and jdat['@attr'].nowplaying then
		message = '🎵  ' .. msg.from.first_name .. ' is listening to:\n'
	end

	local name = jdat.name or 'Unknown'
	local artist
	if jdat.artist then
		artist = jdat.artist['#text']
	else
		artist = 'Unknown'
	end

	local message = message .. name .. ' - ' .. artist

	send_message(msg.chat.id, message)

end

return PLUGIN
