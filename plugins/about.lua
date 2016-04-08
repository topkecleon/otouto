local about = {}

local bindings = require('bindings')

about.command = 'about'
about.doc = '`Returns information about the bot.`'

about.triggers = {
	''
}

function about:action(msg)

	-- Filthy hack, but here is where we'll stop forwarded messages from hitting
	-- other plugins.
	if msg.forward_from then return end

	local message = self.config.about_text .. '\nBased on @otouto v'..self.version..' by topkecleon.'

	if msg.new_chat_participant and msg.new_chat_participant.id == self.info.id then
		bindings.sendMessage(self, msg.chat.id, message, true)
		return
	elseif msg.text_lower:match('^/about[@'..self.info.username..']*') then
		bindings.sendMessage(self, msg.chat.id, message, true)
		return
	elseif msg.text_lower:match('^/start') then
		bindings.sendMessage(self, msg.chat.id, message, true)
		return
	end

	return true

end

return about
