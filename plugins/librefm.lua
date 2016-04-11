local librefm = {}

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('cjson')
local bindings = require('bindings')
local utilities = require('utilities')

function librefm:init()
	if not self.database.librefm then
		self.database.librefm = {}
	end

	librefm.triggers = utilities.triggers(self.info.username):t('librefm', true):t('lnp', true):t('lfmset', true)
end

librefm.command = 'librefm'
librefm.doc = [[```
/lnp [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

/lfmset <username>
Sets your libre.fm username. Otherwise, /np will use your Telegram username. Use "/fmset -" to delete it.
```]]

function librefm:action(msg)

	local input = utilities.input(msg.text)

	if string.match(msg.text, '^/librefm') then
		bindings.sendMessage(self, msg.chat.id, librefm.doc, true, msg.message_id, true)
		return
	elseif string.match(msg.text, '^/lfmset') then
		if not input then
			bindings.sendMessage(self, msg.chat.id, librefm.doc, true, msg.message_id, true)
		elseif input == '-' then
			self.database.lastfm[msg.from.id_str] = nil
			bindings.sendReply(self, msg, 'Your libre.fm username has been forgotten.')
		else
			self.database.lastfm[msg.from.id_str] = input
			bindings.sendReply(self, msg, 'Your libre.fm username has been set to "' .. input .. '".')
		end
		return
	end

	local url = 'http://alpha.libre.fm/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=0&user='

	local username
	local output = ''
	if input then
		username = input
	elseif self.database.lastfm[msg.from.id_str] then
		username = self.database.lastfm[msg.from.id_str]
	elseif msg.from.username then
		username = msg.from.username
		output = '\n\nYour username has been set to ' .. username .. '.\nTo change it, use /lfmset <username>.'
		self.database.lastfm[msg.from.id_str] = username
	else
		bindings.sendReply(self, msg, 'Please specify your libre.fm username or set it with /lfmset.')
		return
	end

	url = url .. URL.escape(username)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		bindings.sendReply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.error then
		bindings.sendReply(self, msg, 'Please specify your libre.fm username or set it with /lfmset.')
		return
	end

	jdat = jdat.recenttracks.track[1] or jdat.recenttracks.track
	if not jdat then
		bindings.sendReply(self, msg, 'No history for this user.' .. output)
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
	bindings.sendMessage(self, msg.chat.id, message)

end

return librefm
