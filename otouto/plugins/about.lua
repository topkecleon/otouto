local about = {}

local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

about.command = 'about'
about.doc = '`Returns information about the bot.`'

about.triggers = {
	''
}

function about:action(msg, config)

	-- Filthy hack, but here is where we'll stop forwarded messages from hitting
	-- other plugins.
	if msg.forward_from then return end

	local output = config.about_text .. '\nBased on otouto v'..bot.version..' by topkecleon.'

	if (msg.new_chat_participant and msg.new_chat_participant.id == self.info.id)
		or msg.text_lower:match('^'..config.cmd_pat..'about')
		or msg.text_lower:match('^'..config.cmd_pat..'about@'..self.info.username:lower())
	or msg.text_lower:match('^'..config.cmd_pat..'start') then
		utilities.send_message(self, msg.chat.id, output, true)
		return
	end

	return true

end

return about
