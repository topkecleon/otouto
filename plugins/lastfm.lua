local PLUGIN = {}

PLUGIN.doc = [[
	/lastfm [username]
	Get current- or last-played track data from last.fm. If a username is specified, it will return info for that username rather than your own.
]]

PLUGIN.triggers = {
	'^/lastfm'
}

function PLUGIN.action(msg)

	local base_url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. config.lastfm_api_key .. '&user='

	local input = get_input(msg.text)
	if not input then
		if msg.from.username then
			input = msg.from.username
		else
			return send_msg(msg, 'Please provide a valid last.fm username.')
		end
	end

	local jstr, res = HTTP.request(base_url..input)

	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)

	if jdat.error then
		return send_msg(msg, jdat.message)
	end

	if not jdat.recenttracks.track then
		return send_msg(msg, 'No history for that user.')
	end

	local jdat = jdat.recenttracks.track[1] or jdat.recenttracks.track

	local message = '🎵  ' .. input .. ' last listened to:\n'
	if jdat['@attr'] and jdat['@attr'].nowplaying then
		message = '🎵  ' .. input .. ' is listening to:\n'
	end

	local message = message .. jdat.name .. ' - ' .. jdat.artist['#text']

	send_message(msg.chat.id, message)

end

return PLUGIN
