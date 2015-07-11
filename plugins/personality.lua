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

function PLUGIN.action(msg)

	local input = string.lower(msg.text)

	if config.people[tostring(msg.from.id)] then msg.from.first_name = config.people[tostring(msg.from.id)] end

	for i = 2, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, 'Welcome back, ' .. msg.from.first_name .. '!')
		end
	end

	interactions = {
		[locale.responses.hello]	= locale.hello,
		[locale.responses.goodbye]	= locale.goodbye,
		[locale.responses.thankyou]	= locale.thankyou,
		[locale.responses.love]		= locale.love,
		[locale.responses.hate]		= locale.hate
	}

	for k,v in pairs(interactions) do
		for key,val in pairs(v) do
			if input:match(val..',? '..bot.first_name) then
				return send_message(msg.chat.id, k..', '..msg.from.first_name..'!')
			end
		end
	end

--	msg.text = '@' .. bot.username .. ', ' .. msg.text:gsub(bot.first_name, '')
--	on_msg_receive(msg)

end

return PLUGIN
