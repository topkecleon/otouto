 -- config.people is a table of IDs/nicknames the bot can address more familiarly
 -- like so:
 -- 	13227902: "Drew"


local PLUGIN = {}

if string.find(bot.first_name, '%-') then
	bot_name = string.lower(string.sub(bot.first_name, 1, string.find(bot.first_name, '%-')-1))
else
	bot_name = string.lower(bot.first_name)
end

PLUGIN.triggers = {
	bot_name .. '%p?$',
	'^tadaima%p?$',
	'^' .. locale.personality.im_home .. '%p?$',
	'^' .. locale.personality.im_back .. '%p?$'
}

function PLUGIN.action(msg)

	local input = string.lower(msg.text)
	local time = tonumber(os.date('%H', os.time()))
	local daytime

	if time >= 17 or time < 05 then
		daytime = 'evening'
	elseif time >= 05 and time <12 then
		daytime = 'morning'
	else
		daytime = 'afternoon'
	end

	if config.people[tostring(msg.from.id)] then msg.from.first_name = config.people[tostring(msg.from.id)] end

	for i = 2,4 do
		if string.match(input, PLUGIN.triggers[i]) then
			local message = locale.personality.responses.welcome
			message = message:gsub('#NAME', msg.from.first_name)
			return send_message(msg.chat.id, message)
		end
	end

	interactions = {
		[locale.personality.responses.hello.morning]		= locale.personality.hello,
		[locale.personality.responses.hello.afternoon]		= locale.personality.hello,
		[locale.personality.responses.hello.evening]		= locale.personality.hello,
		[locale.personality.responses.goodbye.morning]		= locale.personality.goodbye,
		[locale.personality.responses.goodbye.afternoon]	= locale.personality.goodbye,
		[locale.personality.responses.goodbye.evening]		= locale.personality.goodbye,
		[locale.personality.responses.gratitude]		= locale.personality.gratitude,
		[locale.personality.responses.love]			= locale.personality.love,
		[locale.personality.responses.hate]			= locale.personality.hate
	}

	for k,v in pairs(interactions) do
		for key,val in pairs(v) do			
			if input:match(val..',? '..bot_name) then
				local message

				if val[daytime] then
					message = k[daytime]
				else
					message = k
				end

				message = message:gsub('#NAME', msg.from.first_name)

				return send_message(msg.chat.id, message)
			end
		end
	end

--	msg.text = '@' .. bot.username .. ', ' .. msg.text:gsub(bot.first_name, '')
--	on_msg_receive(msg)

end

return PLUGIN
