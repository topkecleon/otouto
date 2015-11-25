 -- This plugin should go at the end of your plugin list in
 -- config.lua, but not after greetings.lua.

local help_text = 'Available commands:\n'

for i,v in ipairs(plugins) do
	if v.doc then
		local a = string.sub(v.doc, 1, string.find(v.doc, '\n')-1)
		help_text =  help_text .. a .. '\n'
	end
end

local help_text = help_text .. 'Arguments: <required> [optional]'

local triggers = {
	'^/h[elp]*[@'..bot.username..']*$',
	'^/start[@'..bot.username..']*'
}

local action = function(msg)

	if msg.from.id ~= msg.chat.id then
		if sendMessage(msg.from.id, help_text) then
			sendReply(msg, 'I have sent you the requested information in a private message.')
		else
			sendReply(msg, help_text)
		end
	else
		sendReply(msg, help_text)
	end

end

return {
	action = action,
	triggers = triggers
}
