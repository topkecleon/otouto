-- utilities.lua
-- Functions shared among plugins.

HTTP = HTTP or require('socket.http')
HTTPS = HTTPS or require('ssl.https')
JSON = JSON or require('cjson')

 -- get the indexed word in a string
get_word = function(s, i)

	s = s or ''
	i = i or 1

	local t = {}
	for w in s:gmatch('%g+') do
		table.insert(t, w)
	end

	return t[i] or false

end

 -- Like get_word(), but better.
 -- Returns the actual index.
function string:index()
	local t = {}
	for w in self:gmatch('%g+') do
		table.insert(t, w)
	end
	return t
end

 -- Returns the string after the first space.
function string:input()
	if not self:find(' ') then
		return false
	end
	return self:sub(self:find(' ')+1)
end

 -- I swear, I copied this from PIL, not yago! :)
function string:trim() -- Trims whitespace from a string.
	local s = self:gsub('^%s*(.-)%s*$', '%1')
	return s
end

local lc_list = {
-- Latin = 'Cyrillic'
	['A'] = 'А',
	['B'] = 'В',
	['C'] = 'С',
	['E'] = 'Е',
	['I'] = 'І',
	['J'] = 'Ј',
	['K'] = 'К',
	['M'] = 'М',
	['H'] = 'Н',
	['O'] = 'О',
	['P'] = 'Р',
	['S'] = 'Ѕ',
	['T'] = 'Т',
	['X'] = 'Х',
	['Y'] = 'Ү',
	['a'] = 'а',
	['c'] = 'с',
	['e'] = 'е',
	['i'] = 'і',
	['j'] = 'ј',
	['o'] = 'о',
	['s'] = 'ѕ',
	['x'] = 'х',
	['y'] = 'у',
	['!'] = 'ǃ'
}

 -- Replaces letters with corresponding Cyrillic characters.
latcyr = function(str)
	for k,v in pairs(lc_list) do
		str = str:gsub(k, v)
	end
	return str
end

 -- Loads a JSON file as a table.
load_data = function(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

 -- Saves a table to a JSON file.
save_data = function(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end

 -- Gets coordinates for a location. Used by gMaps.lua, time.lua, weather.lua.
get_coords = function(input)

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return config.errors.connection
	end

	local jdat = JSON.decode(jstr)
	if jdat.status == 'ZERO_RESULTS' then
		return config.errors.results
	end

	return {
		lat = jdat.results[1].geometry.location.lat,
		lon = jdat.results[1].geometry.location.lng
	}

end

 -- Get the number of values in a key/value table.
table_size = function(tab)

	local i = 0
	for k,v in pairs(tab) do
		i = i + 1
	end
	return i

end

 -- Just an easy way to get a user's full name.
build_name = function(first, last)
	if last then
		return first .. ' ' .. last
	else
		return first
	end
end

resolve_username = function(input)

	input = input:gsub('^@', '')
	for k,v in pairs(database.users) do
		if v.username and v.username:lower() == input:lower() then
			return v
		end
	end

end

user_from_message = function(msg)

	local input = msg.text_lower:input()
	local target = {}
	if msg.reply_to_message then
		target = msg.reply_to_message.from
	elseif input and tonumber(input) then
		target.id = tonumber(input)
		if database.users[input] then
			for k,v in pairs(database.users[input]) do
				target[k] = v
			end
		end
	elseif input and input:match('^@') then
		local uname = input:gsub('^@', '')
		for k,v in pairs(database.users) do
			if v.username and uname == v.username:lower() then
				for key, val in pairs(v) do
					target[key] = val
				end
			end
		end
		if not target.id then
			target.err = 'Sorry, I don\'t recognize that username.'
		end
	else
		target.err = 'Please specify a user via reply, ID, or username.'
	end

	if target.id then
		target.id_str = tostring(target.id)
	end

	if not target.first_name then target.first_name = 'User' end

	target.name = build_name(target.first_name, target.last_name)

	return target

end

handle_exception = function(err, message)

	if not err then err = '' end

	local output = '\n[' .. os.date('%F %T', os.time()) .. ']\n' .. bot.username .. ': ' .. err .. '\n' .. message .. '\n'

	if config.log_chat then
		output = '```' .. output .. '```'
		sendMessage(config.log_chat, output, true, nil, true)
	else
		print(output)
	end

end

 -- Okay, this one I actually did copy from yagop.
 -- https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
download_file = function(url, filename)

	local respbody = {}
	local options = {
		url = url,
		sink = ltn12.sink.table(respbody),
		redirect = true
	}

	local response = nil

	if url:match('^https') then
		options.redirect = false
		response = { HTTPS.request(options) }
	else
		response = { HTTP.request(options) }
	end

	local code = response[2]
	local headers = response[3]
	local status = response[4]

	if code ~= 200 then return false end

	filename = filename or '/tmp/' .. os.time()

	local file = io.open(filename, 'w+')
	file:write(table.concat(respbody))
	file:close()

	return filename

end

markdown_escape = function(text)

	text = text:gsub('_', '\\_')
	text = text:gsub('%[', '\\[')
	text = text:gsub('%*', '\\*')
	text = text:gsub('`', '\\`')
	return text

end

function string:md_escape()
	local text = self
	text = text:gsub('_', '\\_')
	text = text:gsub('%[', '\\[')
	text = text:gsub('%*', '\\*')
	text = text:gsub('`', '\\`')
	return text
end

enrich_user = function(user)
	user.id_str = tostring(user.id)
	user.name = build_name(user.first_name, user.last_name)
	return user
end

enrich_message = function(msg)
	if not msg.text then msg.text = msg.caption or '' end
	msg.text_lower = msg.text:lower()
	msg.from = enrich_user(msg.from)
	msg.chat.id_str = tostring(msg.chat.id)
	if msg.reply_to_message then
		if not msg.reply_to_message.text then
			msg.reply_to_message.text = msg.reply_to_message.caption or ''
		end
		msg.reply_to_message.text_lower = msg.reply_to_message.text:lower()
		msg.reply_to_message.from = enrich_user(msg.reply_to_message.from)
		msg.reply_to_message.chat.id_str = tostring(msg.reply_to_message.chat.id)
	end
	if msg.forward_from then
		msg.forward_from = enrich_user(msg.forward_from)
	end
	if msg.new_chat_participant then
		msg.new_chat_participant = enrich_user(msg.new_chat_participant)
	end
	if msg.left_chat_participant then
		msg.left_chat_participant = enrich_user(msg.left_chat_participant)
	end
	return msg
end
