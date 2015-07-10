 -- config.people is a table of IDs/nicknames the bot can address more familiarly
 -- like so:
 -- 	13227902: "Drew"


local PLUGIN = {}

PLUGIN.triggers = {
	bot.first_name .. '%p?$',
	'^tadaima%p?$',
	'^i\'m home%p?$',
	'^i\'m back%p?$'
}

function PLUGIN.action(msg) -- I WISH LUA HAD PROPER REGEX SUPPORT

	local input = string.lower(msg.text)

	if config.people[tostring(msg.from.id)] then msg.from.first_name = config.people[tostring(msg.from.id)] end

	for i = 2, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, 'Welcome back, ' .. msg.from.first_name .. '!')
		end
	end

	if input:match('thanks,? '..bot.first_name) or input:match('thank you,? '..bot.first_name) then
		return send_message(msg.chat.id, 'No problem, ' .. msg.from.first_name .. '!')
	end

	if input:match('hello,? '..bot.first_name) or input:match('hey,? '..bot.first_name) or input:match('hi,? '..bot.first_name) then
		return send_message(msg.chat.id, 'Hi, ' .. msg.from.first_name .. '!')
	end

	if input:match('bye,? '..bot.first_name) or input:match('later,? '..bot.first_name) then
		return send_message(msg.chat.id, 'Bye-bye, ' .. msg.from.first_name .. '!')
	end

	if input:match('i hate you,? '..bot.first_name) or input:match('screw you,? '..bot.first_name) or input:match('fuck you,? '..bot.first_name) then
		return send_msg(msg, '; _ ;')
	end

	if string.match(input, 'i love you,? '..bot.first_name) then
		return send_msg(msg, '<3')
	end

--	msg.text = '@' .. bot.username .. ', ' .. msg.text:gsub(bot.first_name, '')
--	on_msg_receive(msg)

end

return PLUGIN
