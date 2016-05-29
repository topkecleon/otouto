local pokedex = {}

local HTTP = require('socket.http')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

pokedex.command = 'pokedex <query>'
pokedex.doc = [[```
/pokedex <query>
Returns a Pokedex entry from pokeapi.co.
Alias: /dex
```]]

function pokedex:init()
	pokedex.triggers = utilities.triggers(self.info.username):t('pokedex', true):t('dex', true).table
end

function pokedex:action(msg)

	bindings.sendChatAction(self, { chat_id = msg.chat.id, action = 'typing' } )

	local input = utilities.input(msg.text_lower)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, pokedex.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'http://pokeapi.co'

	local dex_url = url .. '/api/v1/pokemon/' .. input
	local dex_jstr, res = HTTP.request(dex_url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local dex_jdat = JSON.decode(dex_jstr)

	local desc_url = url .. dex_jdat.descriptions[math.random(#dex_jdat.descriptions)].resource_uri
	local desc_jstr, _ = HTTP.request(desc_url)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local desc_jdat = JSON.decode(desc_jstr)

	local poke_type
	for _,v in ipairs(dex_jdat.types) do
		local type_name = v.name:gsub("^%l", string.upper)
		if not poke_type then
			poke_type = type_name
		else
			poke_type = poke_type .. ' / ' .. type_name
		end
	end
	poke_type = poke_type .. ' type'

	local output = '*' .. dex_jdat.name .. '*\n#' .. dex_jdat.national_id .. ' | ' .. poke_type .. '\n_' .. desc_jdat.description:gsub('POKMON', 'Pokémon'):gsub('Pokmon', 'Pokémon') .. '_'


	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return pokedex
