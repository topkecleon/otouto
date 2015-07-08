-- utilities.lua
-- Functions shared among plugins.

function first_word(str, idx) -- get the indexed word in a string
	str = string.gsub(str, '\n', ' ')
	if not string.find(str, ' ') then return str end
	str = str .. ' '
	if not idx then idx = 1 end
	if idx ~= 1 then
		for i = 2, idx do
			str = string.sub(str, string.find(str, ' ') + 1)
		end
	end
	str = string.sub(str, 1, string.find(str, ' '))
	return string.sub(str, 1, -2)
end

function get_input(text) -- returns string or false
	if not string.find(text, ' ') then
		return false
	end
	return string.sub(text, string.find(text, ' ')+1)
end

function trim_string(text) -- another alias
	return string.gsub(text, "^%s*(.-)%s*$", "%1")
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

function latcyr(str)
	for k,v in pairs(lc_list) do
		str = string.gsub(str, k, v)
	end
	return str
end

function send_msg(msg, message)
	send_message(msg.chat.id, message, true)
end

function get_coords(input)

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return false
	end

	local jdat = JSON.decode(jstr)
	if jdat.status == 'ZERO_RESULTS' then
		return false
	end

	return { lat = jdat.results[1].geometry.location.lat, lon = jdat.results[1].geometry.location.lng }

end
