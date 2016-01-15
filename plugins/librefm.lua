local command = 'librefm'
local doc = [[```
/lnp [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

/lfmset <username>
Sets your libre.fm username. Otherwise, /np will use your Telegram username. Use "/fmset -" to delete it.
```]]

local triggers = {
	'^/libre[@'..bot.username..']*',
	'^/lnp[@'..bot.username..']*',
	'^/lfmset[@'..bot.username..']*'
}

local action = function(msg)

	lastfm = load_data('librefm.json')
	local input = msg.text:input()

	if string.match(msg.text, '^/librefm') then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	elseif string.match(msg.text, '^/lfmset') then
		if not input then
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		elseif input == '-' then
			lastfm[msg.from.id_str] = nil
			sendReply(msg, 'Your libre.fm username has been forgotten.')
		else
			lastfm[msg.from.id_str] = input
			sendReply(msg, 'Your libre.fm username has been set to "' .. input .. '".')
		end
		save_data('librefm.json', lastfm)
		return
	end

	local url = 'http://alpha.libre.fm/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=0&user='

	local username
	local output = ''
	if input then
		username = input
	elseif lastfm[msg.from.id_str] then
		username = lastfm[msg.from.id_str]
	elseif msg.from.username then
		username = msg.from.username
		output = '\n\nYour username has been set to ' .. username .. '.\nTo change it, use /lfmset <username>.'
		lastfm[msg.from.id_str] = username
		save_data('lastfm.json', lastfm)
	else
		sendReply(msg, 'Please specify your libre.fm username or set it with /lfmset.')
		return
	end

	url = url .. URL.escape(username)

	jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.error then
		sendReply(msg, 'Please specify your libre.fm username or set it with /lfmset.')
		return
	end

	local jdat = jdat.recenttracks.track[1] or jdat.recenttracks.track
	if not jdat then
		sendReply(msg, 'No history for this user.' .. output)
		return
	end

	local message = input or msg.from.first_name
	message = '🎵  ' .. message

	if jdat['@attr'] and jdat['@attr'].nowplaying then
		message = message .. ' is currently listening to:\n'
	else
		message = message .. ' last listened to:\n'
	end

	local title = jdat.name or 'Unknown'
	local artist = 'Unknown'
	if jdat.artist then
		artist = jdat.artist['#text']
	end

	message = message .. title .. ' - ' .. artist .. output
	sendMessage(msg.chat.id, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
