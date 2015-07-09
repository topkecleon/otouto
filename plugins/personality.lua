 -- config.people is a table of IDs/nicknames the bot can address more familiarly
 -- like so:
 -- 	13227902: "Drew"

local PLUGIN = {}

PLUGIN.triggers = {
	bot.first_name .. '%p?$',
	'^tadaima%p?$',
	I18N('personality.IM_HOME'),
	I18N('personality.IM_BACK')
}

function PLUGIN.action(msg) -- I WISH LUA HAD PROPER REGEX SUPPORT

	local input = string.lower(msg.text)

	if config.people[tostring(msg.from.id)] then msg.from.first_name = config.people[tostring(msg.from.id)] end

	for i = 2, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, I18N('personality.WELCOME_BACK', {FIRST_NAME = msg.from.first_name}))
		end
	end

	if input:match('thanks,? '..bot.first_name) or input:match('thank you,? '..bot.first_name) then
		return send_message(msg.chat.id, I18N('personality.NO_PROBLEM', {FIRST_NAME = msg.from.first_name}))
	end

	if input:match('hello,? '..bot.first_name) or input:match('hey,? '..bot.first_name) or input:match('hi,? '..bot.first_name) then
		return send_message(msg.chat.id, I18N('personality.HELLO', {FIRST_NAME = msg.from.first_name}))
	end

	if input:match('i hate you,? '..bot.first_name) or input:match('screw you,? '..bot.first_name) or input:match('fuck you,? '..bot.first_name) then
		return send_msg(msg, '; _ ;')
	end

	if string.match(input, 'i love you,? '..bot.first_name) then
		return send_msg(msg, '<3')
	end

end

return PLUGIN
