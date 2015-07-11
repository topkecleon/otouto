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
		This is ]] .. bot.first_name .. [[: a plugin-wielding, multi-purpose Telegram bot.
		Use /help for a list of commands.

		Based on otouto v]] .. VERSION .. [[ by @topkecleon.
		otouto is licensed under the GPLv2.
		topkecleon.github.io/otouto
	]] -- Please do not remove this message.

	send_msg(msg, message)

end

return PLUGIN
