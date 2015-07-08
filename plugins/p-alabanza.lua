local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[alaba <nombre>
	Dice cosas buenas.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'alaba',
	'^' .. config.COMMAND_START .. 'praise',
	--[['alaba a',
	'praise',
	'dile algo bonito a']]
}

function PLUGIN.action(msg)
	
	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end
	
	input = input:gsub("%a", string.upper, 1)
	
	local alabanza = {
		"Prefiero a " .. input .. " que a la belleza matematica",
		input .. " es mejor que la pizza",
		input .. " es mas bonito que los azulejos del cuarto de baño de Verbal",
		"Si tuvierais que elegir entre diez millones de euros e ir al cine con " .. input .. " que película veríais?",
		"Por si secuestran a mi ser más querido para chantajearme, despedíos de " .. input,
		"La cara de " .. input .. " enamora mas que las 7 palabras de Elodin",
		input .. " es mejor que el lado fresco de la almohada",
		"Si me diesen una salchipapa cada vez que " .. input .. " me saca de quicio, moriría de hambre",
		input .. " te quiero",
		"He buscado en internet a alguien que mole más que " .. input .. " y no se han encontrado datos",
		input .. " mola mas que el envoltorio de burbujitas",
		input .. " parece que venga de un anuncio de Coca Cola",
		"Si " .. input .. " jugase al poker sería malísimo, porque tiene una mirada tan alegre que nadie apostaría nada",
		input .. " es mejor que enchufar el USB a la primera",
		input .. " te alegra mas el día que un huevo de dos yemas",
		input .. " en moto es cuquiexpress",
		"La sonrisa de " .. input .. " es como viajar a Londres y que justo te haga sol",
		input .. " sales bien en la foto del DNI",
		"Dios mío, voy a comerle a " .. input .. " hasta los juanetes",
		"Detengan el mundo, " .. input .. " mola",
		"Así de pronto diría que " .. input .. " está partiendo la pana",
		"Cuando pienso en Dios, me viene a la cabeza " .. input .. " sin ropa",
		"No se me ocurre nadie más megachuli que " .. input,
		input .. " tu pelo huele a fresas salvajes",
		"All praise " .. input
	}
	
	math.randomseed(os.time())
	local alabanza = alabanza[math.random(#alabanza)]
	send_msg(msg, alabanza)
	
end

return PLUGIN
