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
	bot_name,
	'^tadaima%p?$',
	I18N('personality.IM_HOME'),
	I18N('personality.IM_BACK'),
	'^sayonara%p?$',
}

function PLUGIN.action(msg) -- I WISH LUA HAD PROPER REGEX SUPPORT

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
			return send_message(msg.chat.id, I18N('personality.WELCOME_RESPONSE', {FIRST_NAME = msg.from.first_name}))
		end
	end

	for k,v in pairs(I18N('personality.GREETING')) do
		if input:match(v .. '(.*) ' .. bot_name) then
			if daytime == 'morning' then
				return send_message(msg.chat.id, I18N('personality.GREETING_RESPONSES.MORNING', {FIRST_NAME = msg.from.first_name}))
			elseif daytime == 'evening' then
				return send_message(msg.chat.id, I18N('personality.GREETING_RESPONSES.EVENING', {FIRST_NAME = msg.from.first_name}))
			else
				return send_message(msg.chat.id, I18N('personality.GREETING_RESPONSES.AFTERNOON', {FIRST_NAME = msg.from.first_name}))
			end
		end
	end

	for k,v in pairs(I18N('personality.FAREWELL')) do
		if input:match(v .. '(.*) ' .. bot_name) or string.match(input, PLUGIN.triggers[5]) then
			if daytime == 'morning' then
				return send_message(msg.chat.id, I18N('personality.FAREWELL_RESPONSES.MORNING', {FIRST_NAME = msg.from.first_name}))
			elseif daytime == 'evening' then
				return send_message(msg.chat.id, I18N('personality.FAREWELL_RESPONSES.EVENING', {FIRST_NAME = msg.from.first_name}))
			else
				return send_message(msg.chat.id, I18N('personality.FAREWELL_RESPONSES.AFTERNOON', {FIRST_NAME = msg.from.first_name}))
			end
		end
	end

	for k,v in pairs(I18N('personality.LOVE')) do
		if input:match(v .. '(.*) ' .. bot_name) then
			return send_message(msg.chat.id, I18N('personality.LOVE_RESPONSE', {FIRST_NAME = msg.from.first_name}))
		end
	end

	for k,v in pairs(I18N('personality.HATE')) do
		if input:match(v .. '(.*) ' .. bot_name) then
			return send_message(msg.chat.id, I18N('personality.HATE_RESPONSE', {FIRST_NAME = msg.from.first_name}))
		end
	end

	for k,v in pairs(I18N('personality.GRATITUDE')) do
		if input:match(v .. '(.*) ' .. bot_name) then
			return send_message(msg.chat.id, I18N('personality.GRATITUDE_RESPONSE', {FIRST_NAME = msg.from.first_name}))
		end
	end

	--msg.text = '@' .. bot.username .. ' ' .. msg.text:gsub(bot.first_name, '')
	--on_msg_receive(msg)
end

return PLUGIN
