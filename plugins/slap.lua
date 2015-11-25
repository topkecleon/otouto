local doc = [[
	/slap [target]
	Give someone a good slap (or worse) through reply or specification of a target.
]]

local triggers = {
	'^/slap[@'..bot.username..']*'
}

local slaps = {
	'$victim was shot by $victor.',
	'$victim was pricked to death.',
	'$victim walked into a cactus while trying to escape $victor.',
	'$victim drowned.',
	'$victim drowned whilst trying to escape $victor.',
	'$victim blew up.',
	'$victim was blown up by $victor.',
	'$victim hit the ground too hard.',
	'$victim fell from a high place.',
	'$victim fell off a ladder.',
	'$victim fell into a patch of cacti.',
	'$victim was doomed to fall by $victor.',
	'$victim was blown from a high place by $victor.',
	'$victim was squashed by a falling anvil.',
	'$victim went up in flames.',
	'$victim burned to death.',
	'$victim was burnt to a crisp whilst fighting $victor.',
	'$victim walked into a fire whilst fighting $victor.',
	'$victim tried to swim in lava.',
	'$victim tried to swim in lava while trying to escape $victor.',
	'$victim was struck by lightning.',
	'$victim was slain by $victor.',
	'$victim got finished off by $victor.',
	'$victim was killed by magic.',
	'$victim was killed by $victor using magic.',
	'$victim starved to death.',
	'$victim suffocated in a wall.',
	'$victim fell out of the world.',
	'$victim was knocked into the void by $victor.',
	'$victim withered away.',
	'$victim was pummeled by $victor.',
	'$victim was fragged by $victor.',
	'$victim was desynchronized.',
	'$victim was wasted.',
	'$victim was busted.',
	'$victim\'s bones are scraped clean by the desolate wind.',
	'$victim has died of dysentery.',
	'$victim fainted.',
	'$victim is out of usable Pokemon! $victim whited out!',
	'$victim is out of usable Pokemon! $victim blacked out!',
	'$victim whited out!',
	'$victim blacked out!',
	'$victim says goodbye to this cruel world.',
	'$victim got rekt.',
	'$victim was sawn in half by $victor.',
	'$victim died. I blame $victor.',
	'$victim was axe-murdered by $victor.',
	'$victim\'s melon was split by $victor.',
	'$victim was slice and diced by $victor.',
	'$victim was split from crotch to sternum by $victor.',
	'$victim\'s death put another notch in $victor\'s axe.',
	'$victim died impossibly!',
	'$victim died from $victor\'s mysterious tropical disease.',
	'$victim escaped infection by dying.',
	'$victim played hot-potato with a grenade.',
	'$victim was knifed by $victor.',
	'$victim fell on his sword.',
	'$victim ate a grenade.',
	'$victim practiced being $victor\'s clay pigeon.',
	'$victim is what\'s for dinner!',
	'$victim was terminated by $victor.',
	'$victim was shot before being thrown out of a plane.',
	'$victim was not invincible.',
	'$victim has encountered an error.',
	'$victim died and reincarnated as a goat.',
	'$victor threw $victim off a building.',
	'$victim is sleeping with the fishes.',
	'$victim got a premature burial.',
	'$victor replaced all of $victim\'s music with Nickelback.',
	'$victor spammed $victim\'s email.',
	'$victor made $victim a knuckle sandwich.',
	'$victor slapped $victim with pure nothing.',
	'$victor hit $victim with a small, interstellar spaceship.',
	'$victim was quickscoped by $victor.',
	'$victor put $victim in check-mate.',
	'$victor RSA-encrypted $victim and deleted the private key.',
	'$victor put $victim in the friendzone.',
	'$victor slaps $victim with a DMCA takedown request!',
	'$victim became a corpse blanket for $victor.',
	'Death is when the monsters get you. Death comes for $victim.',
	'Cowards die many times before their death. $victim never tasted death but once.'
}

local action = function(msg)

	local nicks = load_data('nicknames.json')

	local victim = msg.text:input()
	if msg.reply_to_message then
		if nicks[tostring(msg.reply_to_message.from.id)] then
			victim = nicks[tostring(msg.reply_to_message.from.id)]
		else
			victim = msg.reply_to_message.from.first_name
		end
	end

	local victor = msg.from.first_name
	if nicks[msg.from.id_str] then
		victor = nicks[msg.from.id_str]
	end

	if not victim then
		victim = victor
		victor = bot.first_name
	end

	local message = slaps[math.random(#slaps)]
	message = message:gsub('$victim', victim)
	message = message:gsub('$victor', victor)

	sendMessage(msg.chat.id, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
