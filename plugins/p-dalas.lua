local PLUGIN = {}

PLUGIN.triggers = {
	'^[^' .. config.COMMAND_START .. ']',
}

PLUGIN.dalas = {
	"Criticadme constructivamente",
	"Mas mal",
	"Informate antes de hablar",
	"Me cago en todo lo cagable",
	"Mas mal",
	"Los hateos así sí que son divertidos. Más #DEPDalas por favor que me estoy blockeando de la risa 😂😂😂😂😂😂",
	"Lógica hater: \nDalas es un hijo de puta porque se abrió un Patreon,\npero ahora yo pido dinero sentado en una silla gamer de 280€\nRetrasito!",
	"Lo de \"viva auronplay\" es como el nuevo \"allahu akbar\" xDDDD",
	"Si te digo que hay una moda comunista de gente que no tiene ni puta idea de lo que es el comunismo... ¿Cómo te quedas?",
	"En el comunismo todos son pobres",
	"Me gusta informarme bien y ver distintos puntos de vista. Jejejejej",
	"Es una zorra",
	"No os preocupéis si no sabéis qué es el comunismo\n\nYo tampoco",
	"En el comunismo todo el mundo gana lo mismo",
	"Yo no soy machista pero... Tengo una denuncia por violencia de género",
	"El comunismo se basa en una dictadura",
	"\"Poner una frase entre comillas no la hace parecer más profunda ni te convierte en filósofo.\n\n\nDe nada.\"",
	"¿Por qué los protagonistas hombres de videojuegos son guapos y están musculosos?\nNO SOMOS OBJETOS!! 😱 HEMBRISTAS! VIVAN LOS FIDDLESTICKS!!😠😡",
	"Vaya vaya... creo que a alguien no le gustan mis vídeos. 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂",
	"Últimamente hay una moda muy grande de hembristas/feminazis diciendo que \"El hembrismo no existe\".\n\nSí sí... JAJA ojalá no existiérais, no.",
	"Clever Bot es un IDIOTA. Me habla con FALTAS y encima se quiere FOLLAR A MI NOVIA!?",
	"¿Y si te digo que hay gente retrasada en internet? ¿Cómo te quedas? ¡UOUOUOUO!",
	"Amiguitosmíos...",
	"Retrasito Pambisito",
	"UOOO Chemita te destrosa.",
	"No es una roma.",
	"-Mujeres insultan a otras mujeres por su peso.\n-El patriarcado lo hizo. Muerte a los penes. Sois todos violadores.",
	"Pambisitos míos;\nNo todas las células que encontréis que se llaman \"Patriarcado\" en Agar.io soy yo xDDD\nHAHAHAHHAAHA Estaría bien.",
	"Un estudio revela que la gente que se saca muchas selfies es porque tienen muy poco sexo y demasiado tiempo libre.",
	"A alimentarse se le dice comer\nA ir rápido, correr\nY a subir una foto tuya semidesnud@, se le llama zorrear.\n\nNo te ofendas por la verdad 😘😘",
	"Si tengo que escoger entre fangirls locas y futbolistas hooligans escojo fangirls.\nPor lo menos ellas no dan palizas a otras fandoms.\nAsco.",
	"Los futboleros son esos que se ríen de las fangirls por llorar a sus ídolos, pero ellos bien que lloran cuando pierde su equipo de mierda.",
	"El fútbol es esa puta mierda donde un montón de gente se vuelve literalmente LOCA por una victoria que ellos no consiguieron.",
	"\"No basta con que yo triunfe. Los demás deben fracasar.\"\n\n-Gengis Kan",
	"alluda, el patriarcado me oprime chicxs cxn rxtrxsx importxntx\nsxy sxbnormxl y hxblo con una x pxrqux sxy xmbxcil",
	"◄ ▲ ► ▼ ◄ ▲ ► ▼ ◄ ▲ ► ▼ ◄ ▲ ▼ ◄ ▲ ► ▼ ◄ ▲ ► ▼ ◄▼ ◄ ▲ ► ▼ ◄ ▲ ► ▼▼ ◄ ▲ ►◄ ▲ ► ▼ ◄ ▲ ► ▼ ◄ ▲ ►\n\nLo siento, se me cayó mi bolsa de illuminatis.",
	"EH, ¿qué decís de que yo también fui un bebé?\nYo me creé por mitosis."
}

function PLUGIN.action(msg)
	math.randomseed(os.time())
	send_msg(msg, PLUGIN.dalas[math.random(#PLUGIN.dalas)])
end

return PLUGIN
