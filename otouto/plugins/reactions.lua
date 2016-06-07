 -- Never change this plugin. It was not meant to be changed.
 -- You may add reactions. You must never remove reactions.
 -- You must never restructure. You must never disable this plugin.
 -- - Drew, creator, a year later.

 -- Nevermind, Brayden changed it.
 -- - Drew, just now.

local reactions = {}

local utilities = require('otouto.utilities')

reactions.command = 'reactions'
reactions.doc = '`Returns a list of "reaction" emoticon commands.`'

local mapping = {
	['shrug'] = '¯\\_(ツ)_/¯',
	['lenny'] = '( ͡° ͜ʖ ͡°)',
	['flip'] = '(╯°□°）╯︵ ┻━┻',
	['homo'] = '┌（┌　＾o＾）┐',
	['look'] = 'ಠ_ಠ',
	['shots?'] = 'SHOTS FIRED',
	['facepalm'] = '(－‸ლ)'
}

local help

function reactions:init(config)
	-- Generate a "help" message triggered by "/reactions".
	help = 'Reactions:\n'
	reactions.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('reactions').table
	for trigger,reaction in pairs(mapping) do
		help = help .. '• ' .. config.cmd_pat .. trigger:gsub('.%?', '') .. ': ' .. reaction .. '\n'
		table.insert(reactions.triggers, config.cmd_pat..trigger)
		table.insert(reactions.triggers, config.cmd_pat..trigger..'@'..self.info.username:lower())
	end
end

function reactions:action(msg, config)
	if string.match(msg.text_lower, config.cmd_pat..'reactions') then
		utilities.send_message(self, msg.chat.id, help)
		return
	end
	for trigger,reaction in pairs(mapping) do
		if string.match(msg.text_lower, config.cmd_pat..trigger) then
			utilities.send_message(self, msg.chat.id, reaction)
			return
		end
	end
end

return reactions
