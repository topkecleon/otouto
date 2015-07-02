local PLUGIN = {}

PLUGIN.triggers = {
	'otouto%p?$',
	'^tadaima%p?$',
	'^i\'m home%p?$',
	'^i\'m back%p?$'
}

function PLUGIN.action(msg) -- I WISH LUA HAD PROPER REGEX SUPPORT

	local input = string.lower(msg.text)

	for i = 2, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, 'Welcome back, ' .. msg.from.first_name .. '!')
		end
	end

	if input:match('thanks,? otouto') or input:match('thank you,? otouto') then
		return send_message(msg.chat.id, 'No problem, ' .. msg.from.first_name .. '!')
	end

	if input:match('hello,? otouto') or input:match('hey,? otouto') or input:match('hi,? otouto') then
		return send_message(msg.chat.id, 'Hi, ' .. msg.from.first_name .. '!')
	end

	if input:match('i hate you,? otouto') or input:match('screw you,? otouto') or input:match('fuck you,? otouto') then
		return send_msg(msg, '; _ ;')
	end

	if string.match(input, 'i love you,? otouto') then
		return send_msg(msg, '<3')
	end

end

return PLUGIN
