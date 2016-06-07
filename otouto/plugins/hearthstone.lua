 -- Plugin for the Hearthstone database provided by hearthstonejson.com.

local hearthstone = {}

--local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

function hearthstone:init(config)
	if not self.database.hearthstone or os.time() > self.database.hearthstone.expiration then

		print('Downloading Hearthstone database...')

		-- This stuff doesn't play well with lua-sec. Disable it for now; hack in curl.
		--local jstr, res = HTTPS.request('https://api.hearthstonejson.com/v1/latest/enUS/cards.json')
		--if res ~= 200 then
		--  print('Error connecting to hearthstonejson.com.')
		--  print('hearthstone.lua will not be enabled.')
		--  return
		--end
		--local jdat = JSON.decode(jstr)

		local s = io.popen('curl -s https://api.hearthstonejson.com/v1/latest/enUS/cards.json'):read('*all')
		local d = JSON.decode(s)

		if not d then
			print('Error connecting to hearthstonejson.com.')
			print('hearthstone.lua will not be enabled.')
			return
		end

		self.database.hearthstone = d
		self.database.hearthstone.expiration = os.time() + 600000

		print('Download complete! It will be stored for a week.')

	end

	hearthstone.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('hearthstone', true):t('hs').table
	hearthstone.doc = [[```
]]..config.cmd_pat..[[hearthstone <query>
Returns Hearthstone card info.
Alias: ]]..config.cmd_pat..[[hs
```]]
end

hearthstone.command = 'hearthstone <query>'

local function format_card(card)

	local ctype = card.type
	if card.race then
		ctype = card.race
	end
	if card.rarity then
		ctype = card.rarity .. ' ' .. ctype
	end
	if card.playerClass then
		ctype = ctype .. ' (' .. card.playerClass .. ')'
	elseif card.faction then
		ctype = ctype .. ' (' .. card.faction .. ')'
	end

	local stats
	if card.cost then
		stats = card.cost .. 'c'
		if card.attack then
			stats = stats .. ' | ' .. card.attack .. 'a'
		end
		if card.health then
			stats = stats .. ' | ' .. card.health .. 'h'
		end
		if card.durability then
			stats = stats .. ' | ' .. card.durability .. 'd'
		end
	elseif card.health then
		stats = card.health .. 'h'
	end

	-- unused?
	local info
	if card.text then
		info = card.text:gsub('</?.->',''):gsub('%$','')
		if card.flavor then
			info = info .. '\n_' .. card.flavor .. '_'
		end
	elseif card.flavor then
		info = card.flavor
	else
		info = nil
	end

	local s = '*' .. card.name .. '*\n' .. ctype
	if stats then
		s = s .. '\n' .. stats
	end
	if info then
		s = s .. '\n' .. info
	end

	return s

end

function hearthstone:action(msg, config)

	local input = utilities.input(msg.text_lower)
	if not input then
		utilities.send_message(self, msg.chat.id, hearthstone.doc, true, msg.message_id, true)
		return
	end

	local output = ''
	for _,v in pairs(self.database.hearthstone) do
		if type(v) == 'table' and string.lower(v.name):match(input) then
			output = output .. format_card(v) .. '\n\n'
		end
	end

	output = utilities.trim(output)
	if output:len() == 0 then
		utilities.send_reply(self, msg, config.errors.results)
		return
	end

	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return hearthstone
