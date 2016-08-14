local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

local about = {}

about.command = 'about'
about.doc = 'Returns information about the bot.'

function about:init(config)
	about.text = config.about_text .. '\nBased on [otouto](http://github.com/topkecleon/otouto) v'..bot.version..' by topkecleon.'
	about.triggers = utilities.triggers(self.info.username, config.cmd_pat)
		:t('about'):t('start').table
end

function about:action(msg, config)
	utilities.send_message(self, msg.chat.id, about.text, true, nil, true)
end

return about
