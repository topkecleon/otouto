-- utilities.lua
-- Functions shared among plugins.

local utilities = {}

local HTTP = require('socket.http')
local ltn12 = require('ltn12')
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('otouto.bindings')

 -- For the sake of ease to new contributors and familiarity to old contributors,
 -- we'll provide a couple of aliases to real bindings here.
function utilities:send_message(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)
	return bindings.request(self, 'sendMessage', {
		chat_id = chat_id,
		text = text,
		disable_web_page_preview = disable_web_page_preview,
		reply_to_message_id = reply_to_message_id,
		parse_mode = use_markdown and 'Markdown' or nil
	} )
end

function utilities:send_reply(old_msg, text, use_markdown)
	return bindings.request(self, 'sendMessage', {
		chat_id = old_msg.chat.id,
		text = text,
		disable_web_page_preview = true,
		reply_to_message_id = old_msg.message_id,
		parse_mode = use_markdown and 'Markdown' or nil
	} )
end

 -- get the indexed word in a string
function utilities.get_word(s, i)
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
function utilities.index(s)
	local t = {}
	for w in s:gmatch('%g+') do
		table.insert(t, w)
	end
	return t
end

 -- Returns the string after the first space.
function utilities.input(s)
	if not s:find(' ') then
		return false
	end
	return s:sub(s:find(' ')+1)
end

-- Calculates the length of the given string as UTF-8 characters
function utilities.utf8_len(s)
    local chars = 0
    for i = 1, string.len(s) do
        local b = string.byte(s, i)
        if b < 128 or b >= 192 then
            chars = chars + 1
        end
    end
    return chars
end

 -- Trims whitespace from a string.
function utilities.trim(str)
	local s = str:gsub('^%s*(.-)%s*$', '%1')
	return s
end

 -- Loads a JSON file as a table.
function utilities.load_data(filename)
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
function utilities.save_data(filename, data)
	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()
end

 -- Gets coordinates for a location. Used by gMaps.lua, time.lua, weather.lua.
function utilities.get_coords(input, config)

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
function utilities.table_size(tab)
	local i = 0
	for _,_ in pairs(tab) do
		i = i + 1
	end
	return i
end

 -- Just an easy way to get a user's full name.
 -- Alternatively, abuse it to concat two strings like I do.
function utilities.build_name(first, last)
	if last then
		return first .. ' ' .. last
	else
		return first
	end
end

function utilities:resolve_username(input)
	input = input:gsub('^@', '')
	for _, user in pairs(self.database.users) do
		if user.username and user.username:lower() == input:lower() then
			local t = {}
			for key, val in pairs(user) do
				t[key] = val
			end
			return t
		end
	end
end

 -- Simpler than above function; only returns an ID.
 -- Returns nil if no ID is available.
function utilities:id_from_username(input)
	input = input:gsub('^@', '')
	for _, user in pairs(self.database.users) do
		if user.username and user.username:lower() == input:lower() then
			return user.id
		end
	end
end

 -- Simpler than below function; only returns an ID.
 -- Returns nil if no ID is available.
function utilities:id_from_message(msg)
	if msg.reply_to_message then
		return msg.reply_to_message.from.id
	else
		local input = utilities.input(msg.text)
		if input then
			if tonumber(input) then
				return tonumber(input)
			elseif input:match('^@') then
				return utilities.id_from_username(self, input)
			end
		end
	end
end

function utilities:user_from_message(msg, no_extra)

	local input = utilities.input(msg.text_lower)
	local target = {}
	if msg.reply_to_message then
		for k,v in pairs(self.database.users[msg.reply_to_message.from.id_str]) do
			target[k] = v
		end
	elseif input and tonumber(input) then
		target.id = tonumber(input)
		if self.database.users[input] then
			for k,v in pairs(self.database.users[input]) do
				target[k] = v
			end
		end
	elseif input and input:match('^@') then
		local uname = input:gsub('^@', '')
		for _,v in pairs(self.database.users) do
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

	if not no_extra then
		if target.id then
			target.id_str = tostring(target.id)
		end
		if not target.first_name then
			target.first_name = 'User'
		end
		target.name = utilities.build_name(target.first_name, target.last_name)
	end

	return target

end

function utilities:handle_exception(err, message, config)

	if not err then err = '' end

	local output = '\n[' .. os.date('%F %T', os.time()) .. ']\n' .. self.info.username .. ': ' .. err .. '\n' .. message .. '\n'

	if config.log_chat then
		output = '```' .. output .. '```'
		utilities.send_message(self, config.log_chat, output, true, nil, true)
	else
		print(output)
	end

end

function utilities.download_file(url, filename)
	if not filename then
		filename = url:match('.+/(.-)$') or os.time()
		filename = '/tmp/' .. filename
	end
	local body = {}
	local doer = HTTP
	local do_redir = true
	if url:match('^https') then
		doer = HTTPS
		do_redir = false
	end
	local _, res = doer.request{
		url = url,
		sink = ltn12.sink.table(body),
		redirect = do_redir
	}
	if res ~= 200 then return false end
	local file = io.open(filename, 'w+')
	file:write(table.concat(body))
	file:close()
	return filename
end

function utilities.markdown_escape(text)
	text = text:gsub('_', '\\_')
	text = text:gsub('%[', '\\[')
	text = text:gsub('%]', '\\]')
	text = text:gsub('%*', '\\*')
	text = text:gsub('`', '\\`')
	return text
end

utilities.md_escape = utilities.markdown_escape

utilities.triggers_meta = {}
utilities.triggers_meta.__index = utilities.triggers_meta
function utilities.triggers_meta:t(pattern, has_args)
	local username = self.username:lower()
	table.insert(self.table, '^'..self.cmd_pat..pattern..'$')
	table.insert(self.table, '^'..self.cmd_pat..pattern..'@'..username..'$')
	if has_args then
		table.insert(self.table, '^'..self.cmd_pat..pattern..'%s+[^%s]*')
		table.insert(self.table, '^'..self.cmd_pat..pattern..'@'..username..'%s+[^%s]*')
	end
	return self
end

function utilities.triggers(username, cmd_pat, trigger_table)
	local self = setmetatable({}, utilities.triggers_meta)
	self.username = username
	self.cmd_pat = cmd_pat
	self.table = trigger_table or {}
	return self
end

function utilities.with_http_timeout(timeout, fun)
	local original = HTTP.TIMEOUT
	HTTP.TIMEOUT = timeout
	fun()
	HTTP.TIMEOUT = original
end

function utilities.pretty_float(x)
	if x % 1 == 0 then
		return tostring(math.floor(x))
	else
		return tostring(x)
	end
end

 -- This table will store unsavory characters that are not properly displayed,
 -- or are just not fun to type.
utilities.char = {
	zwnj = '‌',
	arabic = '[\216-\219][\128-\191]',
	rtl_override = '‮',
	rtl_mark = '‏',
	em_dash = '—',
	utf_8 = '([%z\1-\127\194-\244][\128-\191]*)',
}

return utilities
