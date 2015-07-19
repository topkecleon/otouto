 -- config.people is a table of IDs/nicknames the bot can address more familiarly
 -- like so:
 -- 	13227902: "Drew"


local PLUGIN = {}

PLUGIN.no_typing = true

PLUGIN.triggers = {
	bot.first_name .. '%p?$',
	'@' .. bot.username .. '%p?$',
	'^tadaima%p?$',
	'^i\'m home%p?$',
	'^i\'m back%p?$'
}

function PLUGIN.action(msg)

	local input = string.lower(msg.text)

	if config.people[tostring(msg.from.id)] then msg.from.first_name = config.people[tostring(msg.from.id)] end

	for i = 3, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, 'Welcome back, ' .. msg.from.first_name .. '!')
		end
	end

	for k,v in pairs(config.locale.interactions) do
		for key,val in pairs(v) do
			if input:match(val..',? '..bot.first_name) then
				return send_message(msg.chat.id, k:gsub('#NAME', msg.from.first_name))
			end
		end
	end

end

return PLUGIN
