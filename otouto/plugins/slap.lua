local slap = {}

local utilities = require('otouto.utilities')

slap.command = 'slap [target]'

function slap:init(config)
	slap.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('slap', true).table
	slap.doc = [[```
]]..config.cmd_pat..[[slap [target]
Slap somebody.
```]]
end

local slaps = {
	'VICTIM was shot by VICTOR.',
	'VICTIM was pricked to death.',
	'VICTIM walked into a cactus while trying to escape VICTOR.',
	'VICTIM drowned.',
	'VICTIM drowned whilst trying to escape VICTOR.',
	'VICTIM blew up.',
	'VICTIM was blown up by VICTOR.',
	'VICTIM hit the ground too hard.',
	'VICTIM fell from a high place.',
	'VICTIM fell off a ladder.',
	'VICTIM fell into a patch of cacti.',
	'VICTIM was doomed to fall by VICTOR.',
	'VICTIM was blown from a high place by VICTOR.',
	'VICTIM was squashed by a falling anvil.',
	'VICTIM went up in flames.',
	'VICTIM burned to death.',
	'VICTIM was burnt to a crisp whilst fighting VICTOR.',
	'VICTIM walked into a fire whilst fighting VICTOR.',
	'VICTIM tried to swim in lava.',
	'VICTIM tried to swim in lava while trying to escape VICTOR.',
	'VICTIM was struck by lightning.',
	'VICTIM was slain by VICTOR.',
	'VICTIM got finished off by VICTOR.',
	'VICTIM was killed by magic.',
	'VICTIM was killed by VICTOR using magic.',
	'VICTIM starved to death.',
	'VICTIM suffocated in a wall.',
	'VICTIM fell out of the world.',
	'VICTIM was knocked into the void by VICTOR.',
	'VICTIM withered away.',
	'VICTIM was pummeled by VICTOR.',
	'VICTIM was fragged by VICTOR.',
	'VICTIM was desynchronized.',
	'VICTIM was wasted.',
	'VICTIM was busted.',
	'VICTIM\'s bones are scraped clean by the desolate wind.',
	'VICTIM has died of dysentery.',
	'VICTIM fainted.',
	'VICTIM is out of usable Pokemon! VICTIM whited out!',
	'VICTIM is out of usable Pokemon! VICTIM blacked out!',
	'VICTIM whited out!',
	'VICTIM blacked out!',
	'VICTIM says goodbye to this cruel world.',
	'VICTIM got rekt.',
	'VICTIM was sawn in half by VICTOR.',
	'VICTIM died. I blame VICTOR.',
	'VICTIM was axe-murdered by VICTOR.',
	'VICTIM\'s melon was split by VICTOR.',
	'VICTIM was sliced and diced by VICTOR.',
	'VICTIM was split from crotch to sternum by VICTOR.',
	'VICTIM\'s death put another notch in VICTOR\'s axe.',
	'VICTIM died impossibly!',
	'VICTIM died from VICTOR\'s mysterious tropical disease.',
	'VICTIM escaped infection by dying.',
	'VICTIM played hot-potato with a grenade.',
	'VICTIM was knifed by VICTOR.',
	'VICTIM fell on his sword.',
	'VICTIM ate a grenade.',
	'VICTIM practiced being VICTOR\'s clay pigeon.',
	'VICTIM is what\'s for dinner!',
	'VICTIM was terminated by VICTOR.',
	'VICTIM was shot before being thrown out of a plane.',
	'VICTIM was not invincible.',
	'VICTIM has encountered an error.',
	'VICTIM died and reincarnated as a goat.',
	'VICTOR threw VICTIM off a building.',
	'VICTIM is sleeping with the fishes.',
	'VICTIM got a premature burial.',
	'VICTOR replaced all of VICTIM\'s music with Nickelback.',
	'VICTOR spammed VICTIM\'s email.',
	'VICTOR made VICTIM a knuckle sandwich.',
	'VICTOR slapped VICTIM with pure nothing.',
	'VICTOR hit VICTIM with a small, interstellar spaceship.',
	'VICTIM was quickscoped by VICTOR.',
	'VICTOR put VICTIM in check-mate.',
	'VICTOR RSA-encrypted VICTIM and deleted the private key.',
	'VICTOR put VICTIM in the friendzone.',
	'VICTOR slaps VICTIM with a DMCA takedown request!',
	'VICTIM became a corpse blanket for VICTOR.',
	'Death is when the monsters get you. Death comes for VICTIM.',
	'Cowards die many times before their death. VICTIM never tasted death but once.',
	'VICTIM died of hospital gangrene.',
	'VICTIM got a house call from Doctor VICTOR.',
	'VICTOR beheaded VICTIM.',
	'VICTIM got stoned...by an angry mob.',
	'VICTOR sued the pants off VICTIM.',
	'VICTIM was impeached.',
	'VICTIM was one-hit KO\'d by VICTOR.',
	'VICTOR sent VICTIM to /dev/null.',
	'VICTOR sent VICTIM down the memory hole.',
	'VICTIM was a mistake.',
	'"VICTIM was a mistake." - VICTOR',
	'VICTOR checkmated VICTIM in two moves.'
}

 -- optimize later
function slap:action(msg)
	local input = utilities.input(msg.text)
	local victor_id = msg.from.id
	local victim_id = utilities.id_from_message(self, msg)
	-- IDs
	if victim_id then
		if victim_id == victor_id then
			victor_id = self.info.id
		end
	else
		if not input then
			victor_id = self.info.id
			victim_id = msg.from.id
		end
	end
	-- Names
	local victor_name, victim_name
	if input and not victim_id then
		victim_name = input
	else
		local victim_id_str = tostring(victim_id)
		if self.database.userdata[victim_id_str] and self.database.userdata[victim_id_str].nickname then
			victim_name = self.database.userdata[victim_id_str].nickname
		elseif self.database.users[victim_id_str] then
			victim_name = utilities.build_name(self.database.users[victim_id_str].first_name, self.database.users[victim_id_str].last_name)
		else
			victim_name = victim_id_str
		end
	end
	local victor_id_str = tostring(victor_id)
	if self.database.userdata[victor_id_str] and self.database.userdata[victor_id_str].nickname then
		victor_name = self.database.userdata[victor_id_str].nickname
	elseif self.database.users[victor_id_str] then
		victor_name = utilities.build_name(self.database.users[victor_id_str].first_name, self.database.users[victor_id_str].last_name)
	else
		victor_name = self.info.first_name
	end
	local output = utilities.char.zwnj .. slaps[math.random(#slaps)]:gsub('VICTIM', victim_name):gsub('VICTOR', victor_name)
	utilities.send_message(self, msg.chat.id, output)
end

return slap
