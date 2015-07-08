local PLUGIN = {}

PLUGIN.triggers = {
	'peto',
	'^tadaima',
	'^sayonara',
	'^estoy en casa%p?$',
	'^he vuelto%p?$'
}

function PLUGIN.action(msg) -- I WISH LUA HAD PROPER REGEX SUPPORT

	local input = string.lower(msg.text)
	local time = tonumber(os.date('%H%M', os.time()))
	local daytime
	local greeting

	if time > 1900 and time < 100 then
		daytime = 'evening'
	elseif time > 0100 and time < 1030 then
		daytime = 'morning'
	else
		daytime = 'day'
	end

	if string.match(input, PLUGIN.triggers[2]) then
		return send_message(msg.chat.id, 'Okaeri nasai, ' .. msg.from.first_name .. '! 😄')
	end

	if input:match('gracias(.*) peto') or input:match('buen (.*) peto') or input:match('bien(.*) peto') or input:match('grande(.*) peto') then

		return send_message(msg.chat.id, 'Arigatō ' .. msg.from.first_name .. '! 😊')

	elseif input:match('hola(.*) peto') or input:match('hey(.*) peto') or input:match('hi(.*) peto') or input:match('buenos dias(.*) peto') then

		if daytime == 'morning' then
			greeting = 'Ohayō gozaimasu'
		elseif daytime == 'evening' then
			greeting = 'Konban wa'
		else
			greeting = 'Konnichi wa'
		end

		return send_message(msg.chat.id, greeting .. ' ' .. msg.from.first_name .. '! 😊')

	elseif input:match('mal(.*) peto') or input:match('que te den(.*) peto') or input:match('fatal(.*) peto') then

		return send_msg(msg, 'Gomen nasai... 😭')

	elseif string.match(input, 'te quiero(.*) peto') then

		return send_msg(msg, '😣')

	elseif input:match('say?') or input:match('adios(.*) peto') or input:match('hasta luego(.*) peto') or input:match('nos vemos(.*) peto') or input:match('bye(.*) peto') or input:match('buenas noches(.*) peto')then

		if daytime == 'evening' then
			greeting = 'Oyasumi nasai'
		else
			greeting = 'Sayōnara'
		end

		return send_message(msg.chat.id, greeting .. ' ' .. msg.from.first_name .. '! 😊')

	end

end

return PLUGIN
