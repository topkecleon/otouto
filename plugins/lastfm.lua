if not config.lastfm_api_key then
	print('Missing config value: lastfm_api_key.')
	print('lastfm.lua will not be enabled.')
	return
end

if not database.lastfm then
	database.lastfm = {}
end

local HTTP = require('socket.http')
HTTP.TIMEOUT = 1

local command = 'lastfm'
local doc = [[```
/np [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

/fmset <username>
Sets your last.fm username. Otherwise, /np will use your Telegram username. Use "/fmset -" to delete it.
```]]

local triggers = {
	'^/lastfm[@'..bot.username..']*',
	'^/np[@'..bot.username..']*',
	'^/fmset[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()

	if string.match(msg.text, '^/lastfm') then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	elseif string.match(msg.text, '^/fmset') then
		if not input then
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		elseif input == '-' then
			database.lastfm[msg.from.id_str] = nil
			sendReply(msg, 'Your last.fm username has been forgotten.')
		else
			database.lastfm[msg.from.id_str] = input
			sendReply(msg, 'Your last.fm username has been set to "' .. input .. '".')
		end
		return
	end

	local url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. config.lastfm_api_key .. '&user='

	local username
	local output = ''
	if input then
		username = input
	elseif database.lastfm[msg.from.id_str] then
		username = database.lastfm[msg.from.id_str]
	elseif msg.from.username then
		username = msg.from.username
		output = '\n\nYour username has been set to ' .. username .. '.\nTo change it, use /fmset <username>.'
		database.lastfm[msg.from.id_str] = username
	else
		sendReply(msg, 'Please specify your last.fm username or set it with /fmset.')
		return
	end

	url = url .. URL.escape(username)

	jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.error then
		sendReply(msg, 'Please specify your last.fm username or set it with /fmset.')
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
