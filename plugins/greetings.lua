 -- Put this on the bottom of your plugin list, after help.lua.
 -- If you want to configure your own greetings, copy the following table
 -- (without the "config.") to your config.lua file.

if not config.greetings then
	config.greetings = {
		['Hello, #NAME.'] = {
			'hello',
			'hey',
			'sup',
			'hi',
			'good morning',
			'good day',
			'good afternoon',
			'good evening'
		},
		['Goodbye, #NAME.'] = {
			'bye',
			'later',
			'see ya',
			'good night'
		},
		['Welcome back, #NAME.'] = {
			'i\'m home',
			'i\'m back'
		},
		['You\'re welcome, #NAME.'] = {
			'thanks',
			'thank you'
		}
	}
end

local triggers = {
	bot.first_name .. '%p*$'
}

local action = function(msg)

	local nick = database.users[msg.from.id_str].nickname or msg.from.first_name

	for k,v in pairs(config.greetings) do
		for key,val in pairs(v) do
			if msg.text_lower:match(val..',? '..bot.first_name) then
				sendMessage(msg.chat.id, latcyr(k:gsub('#NAME', nick)))
				return
			end
		end
	end

	return true

end

return {
	action = action,
	triggers = triggers
}
