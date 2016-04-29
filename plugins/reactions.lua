 -- Never change this plugin. It was not meant to be changed.
 -- You may add reactions. You must never remove reactions.
 -- You must never restructure. You must never disable this plugin.
 -- ~ Drew, creator, a year later.

local reactions = {}

local bindings = require('bindings')
local utilities = require('utilities')

reactions.command = 'reactions'
reactions.doc = '`Returns a list of "reaction" emoticon commands.`'

local mapping = {
	['shrug'] = '¯\\_(ツ)_/¯',
	['lenny'] = '( ͡° ͜ʖ ͡°)',
	['flip'] = '(╯°□°）╯︵ ┻━┻',
	['homo'] = '┌（┌　＾o＾）┐',
	['look'] = 'ಠ_ಠ',
	['shots?'] = 'SHOTS FIRED'
}

local help

function reactions:init()
	-- Generate a "help" message triggered by "/reactions".
	local help = 'Reactions:\n'
	reactions.triggers = utilities.triggers(self.info.username):t('reactions').table
	for trigger,reaction in pairs(mapping) do
		help = help .. '• ' .. trigger:gsub('.%?', '') .. ': ' .. reaction .. '\n'
		table.insert(reactions.triggers, utilities.INVOCATION_PATTERN..trigger)
		table.insert(reactions.triggers, utilities.INVOCATION_PATTERN..trigger..'@'..self.info.username:lower())
	end
end

function reactions:action(msg)
	if string.match(msg.text_lower, utilities.INVOCATION_PATTERN..'help') then
		bindings.sendMessage(self, msg.chat.id, help)
		return
	end
	for trigger,reaction in pairs(mapping) do
		if string.match(msg.text_lower, utilities.INVOCATION_PATTERN..trigger) then
			bindings.sendMessage(self, msg.chat.id, reaction)
			return
		end
	end
end

return reactions
