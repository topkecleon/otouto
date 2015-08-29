local PLUGIN = {}

PLUGIN.doc = [[
	/slap [victim]
	Slap someone!
]]

PLUGIN.triggers = {
	'^/slap'
}

function PLUGIN.getSlap(slapper, victim)
	slaps = {
		victim .. " was shot by " .. slapper .. ".",
		victim .. " was pricked to death.",
		victim .. " walked into a cactus while trying to escape " .. slapper .. ".",
		victim .. " drowned.",
		victim .. " drowned whilst trying to escape " .. slapper .. ".",
		victim .. " blew up.",
		victim .. " was blown up by " .. slapper .. ".",
		victim .. " hit the ground too hard.",
		victim .. " fell from a high place.",
		victim .. " fell off a ladder.",
		victim .. " fell into a patch of cacti.",
		victim .. " was doomed to fall by " .. slapper .. ".",
		victim .. " was blown from a high place by " .. slapper .. ".",
		victim .. " was squashed by a falling anvil.",
		victim .. " went up in flames.",
		victim .. " burned to death.",
		victim .. " was burnt to a crisp whilst fighting " .. slapper .. ".",
		victim .. " walked into a fire whilst fighting " .. slapper .. ".",
		victim .. " tried to swim in lava.",
		victim .. " tried to swim in lava while trying to escape " .. slapper .. ".",
		victim .. " was struck by lightning.",
		victim .. " was slain by " .. slapper .. ".",
		victim .. " got finished off by " .. slapper .. ".",
		victim .. " was killed by magic.",
		victim .. " was killed by " .. slapper .. " using magic.",
		victim .. " starved to death.",
		victim .. " suffocated in a wall.",
		victim .. " fell out of the world.",
		victim .. " was knocked into the void by " .. slapper .. ".",
		victim .. " withered away.",
		victim .. " was pummeled by " .. slapper .. ".",
		victim .. " was fragged by " .. slapper .. ".",
		victim .. " was desynchronized.",
		victim .. " was wasted.",
		victim .. " was busted by " .. slapper .. ".",
		victim .. "'s bones are scraped clean by the desolate wind.",
		victim .. " has died of dysentery.",
		victim .. " fainted.",
		victim .. " is out of usable Pokemon! " .. victim .. " whited out!",
		victim .. " is out of usable Pokemon! " .. victim .. " blacked out!",
		victim .. " whited out!",
		victim .. " blacked out!",
		victim .. " says goodbye to this cruel world.",
		victim .. " got rekt.",
		victim .. " was sawn in half by " .. slapper .. ".",
		victim .. " died. I blame " .. slapper .. ".",
		victim .. " was axe-murdered by " .. slapper .. ".",
		victim .. "'s melon was split by " .. slapper .. ".",
		victim .. " was slice and diced by " .. slapper .. ".",
		victim .. " was split from crotch to sternum by " .. slapper .. ".",
		victim .. "'s death put another notch in " .. slapper .. "'s axe.",
		victim .. " died impossibly!",
		victim .. " died from " .. slapper .. "'s mysterious tropical disease.",
		victim .. " escaped infection by dying.",
		victim .. " played hot-potato with a grenade.",
		victim .. " was knifed by " .. slapper .. ".",
		victim .. " fell on his sword.",
		victim .. " ate a grenade.",
		victim .. " practiced being " .. slapper .. "'s clay pigeon.",
		victim .. " is what's for dinner!",
		victim .. " was terminated by " .. slapper .. ".",
		victim .. " was shot before being thrown out of a plane.",
		victim .. " was not invincible.",
		victim .. " has encountered an error.",
		victim .. " died and reincarnated as a goat.",
		slapper .. " threw " .. victim .. " off a building.",
		victim .. " is sleeping with the fishes.",
		victim .. " got a premature burial.",
		slapper .. " replaced all of " .. victim .. "'s music with Nickelback.",
		slapper .. " spammed " .. victim .. "'s email.",
		slapper .. " made " .. victim .. " a knuckle sandwich.",
		slapper .. " slapped " .. victim .. " with pure nothing.",
		slapper .. " hit " .. victim .. " with a small, interstellar spaceship.",
		victim .. " was quickscoped by " .. slapper .. ".",
		slapper .. " put " .. victim .. " in check-mate.",
		slapper .. " RSA-encrypted " .. victim .. " and deleted the private key.",
		slapper .. " put " .. victim .. " in the friendzone.",
		slapper .. " slaps " .. victim .. " with a DMCA takedown request!",
		victim .. " became a corpse blanket for " .. slapper .. ".",
		"Death is when the monsters get you. Death comes for " .. victim .. ".",
		"Cowards die many times before their death. " .. victim .. " never tasted death but once."
	}
	return slaps[math.random(#slaps)]
end

function PLUGIN.action(msg)

	math.randomseed(os.time())

	local slapper, victim, sid, vid

	victim = get_input(msg.text)
	if victim then
		slapper = msg.from.first_name
	else
		victim = msg.from.first_name
		vid = msg.from.id
		slapper = bot.first_name
	end

	if msg.reply_to_message then
		victim = msg.reply_to_message.from.first_name
		vid = msg.reply_to_message.from.id
		slapper = msg.from.first_name
		sid = msg.from.id
		if slapper == victim then
			slapper = bot.first_name
			sid = bot.id
		end
	end

	nicks = load_data('nicknames.json') -- Try to replace slapper/victim names with nicknames.
	sid = tostring(sid)
	vid = tostring(vid)
	if nicks[sid] then slapper = nicks[sid] end
	if nicks[vid] then victim =  nicks[vid] end

	local message = PLUGIN.getSlap(slapper, victim)
	send_message(msg.chat.id, latcyr(message))

end

return PLUGIN
