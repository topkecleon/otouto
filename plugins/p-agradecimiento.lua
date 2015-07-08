local PLUGIN = {}

PLUGIN.triggers = {
	"bien(.*)",
    "buen(.*)",
    "gracias(.*)",
    "eres un solete",
    "eres una monada",
    "eres muy mona",
    "eres kawaii",
    "eres adorable",
    "eres amor",
    "eres preciosa",
    "eres genial",
    "aw[,]? gracias",
    "accurate",
    "estoy(.*) agradecid[o|a]",
    "gracias(.*) peque",
    "peto(.*) toma una galleta",
    "aw yes",
    "te quiero(.*)"
}

PLUGIN.respuestas = {
    'M-muchas gracias...',
    'N-no hacia falta...',
    '*.*',
    '>.<',
    '*//.//*',
    'Un placer *//.//*',
    'G-gracias, senpai n.n',
    'E-eres muy amable',
    'G-gracias a ti...',
    'U-un placer...'
}

function PLUGIN.action(msg)
	
	math.randomseed(os.time())
	local respuesta = PLUGIN.respuestas[math.random(#PLUGIN.respuestas)]
	send_msg(msg, respuesta)
	
end

return PLUGIN
