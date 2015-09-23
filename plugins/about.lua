local PLUGIN = {}

PLUGIN.doc = [[
	/about
	Information about the bot.
]]

PLUGIN.triggers = {
	'^/about',
	'^/info'
}

function PLUGIN.action(msg)

	local message = [[
		I am ]] .. bot.first_name .. [[: a plugin-wielding, multi-purpose Telegram bot.
		Use /help for a list of commands.

		Based on otouto v]] .. VERSION .. [[ by @topkecleon.
		otouto v2 is licensed under the GPLv2.
		topkecleon.github.io/otouto

		Join the update/news channel!
		telegram.me/otouto
	]] -- Please do not remove this message. ^.^

	send_message(msg.chat.id, message, true)

end

return PLUGIN
