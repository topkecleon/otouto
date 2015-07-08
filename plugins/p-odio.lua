local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[insulta <nombre>
	Se hace respetar.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'insulta',
	'^' .. config.COMMAND_START .. 'putea',
	'^' .. config.COMMAND_START .. 'bullying',
	--[['metete con',
	'putea a',
	'haz bullying a']]
}

PLUGIN.bullying = {
	"eres adoptado",
	"tu familia esta rota",
	"te recomiendo suicidarte, tu mal no tiene cura",
	"estas roto mentalmente",
	"¿sabias que Jose es pro? no, porque eres inutil",
	"mira me cago en tus muertos",
	"eres una ofensa a España",
	"eres peligroso para la media de CI",
	"yo creía en tu",
	"eso te pasa por puta",
	"QUE TE DEN, PERO MUY FUERTE",
	"Franco te quemaba",
	"DIN DIN DIN. ¡SÓCRATES APRUEBA TU COMENTARIO!",
	"me molesta el eco de tu existencia",
	"eres la nueva Jeje",
	"creo que morir es algo tan guay que cuando empiezas no puedes parar",
	"deten el retraso",
	"AL FINAL TE VOY A PEGAR UNA PALIZA GITANA",
	"realmente la tierra estaría mejor sin humanos eh",
	"algún día los científicos tienen que analizar tu cerebro",
	"A TU CASA A HACERTE PAJAS, HIJO",
	"esta cara, este cuerpo, tu jamás tendras este cuerpo",
	"te puedo chafar con mi nabo",
	"te pienso partir las piernas",
	"tanta lefa tragada produce alucinaciones",
	"putas somos todos",
	"ERES UN DENTISTA DE CACA HECHO CON LA CACA DE UNA CACA",
	"lo k t apetesen son poyas xd",
	"tu perro es kawaii",
	"eres tan puta que me da miedo",
	"Kamal se ofrece a golpearte con su pene negro y venoso",
	"recibe una puta",
	"deja de malgastar neuronas, que te quedan pocas",
	"vete a pensar sobre la vida que no tienes",
	"vuelve al útero y abórtate",
	"eres la CASTA",
	"POPULISTA",
	"ROJO",
	"mas tonto y no naces",
	"pedazo de mierda disfuncional",
	"cuando fuiste a comprar una careta de halloween, solo te dieron la goma",
	"eres mas feo que un coche por debajo",
	"deberian darte 2 medallas. Una por tonto y otra por si la pierdes",
	"eres más inútil que la dieta de falete",
	"tu acta de nacimiento es una disculpa de la fábrica de condones",
	"al nacer el medico te lanzó al techo y dijo: 'si vuela es un murciélago, si se queda pegado, un tumor'",
	"me gusta tu presencia... a 1000 kilómetros de aqui",
	"eres tan feo que Mr Jägger haría un vídeo con frases de feos solo para ti",
	"eres tan gordx que si te tiras al vacío lo llenas",
	"eres tan feo que tu madre cuando naciste empezó a buscar la cámara oculta",
	"eres la prueba de que Dios tiene sentido del humor",
	"tu madre tendría que haberte tragado",
	"Ecarus",
	"eres francés",
	"eres tonto y en tu casa no lo saben y el perro lo sospecha",
	"no creo que eso de nacer fuese la mejor idea del mundo",
	"según la OMS tu cara es un riesgo para la salud",
	"desde 2005 la IUPAC te cambió el nombre por 'gilipollas'",
	"me han llamado del zoo y me han dicho que es mejor que vuelvas por tu propio pie, que si vienen ellos va a ser peor",
	"tu existencia refuta la teoría del Diseño Inteligente",
	"eres un tesoro, solo falta que alguien te entierre",
	"das más cáncer que MAS",
	"tu madre deberia haberte tirado y haberse quedado con la cigüeña",
	"no me hace falta insultarte, tu espejo lo hace por mi",
	"no creo que pueda ir tu funeral, pero enviaré una tarjeta de felicitación",
	"¿amas a la naturaleza? ¿después de lo que te ha hecho?",
	"eres tan feo, que al nacer tenias la incubadora con los cristales tintados",
	"eres tan feo que tu madre te cantaba nanas por walkie-talkie",
	"tienes la cara perfecta para salir en la radio",
	"nunca olvido una cara, pero en tu caso estaré encantado de hacer una excepción",
	"eres tan feo que te dijeron 'ven a mi casa, que no hay nadie', llegaste, y no había nadie",
	"se podría decir que tienes suerte, tú nunca podrás morirte de un derrame cerebral",
	"haces llorar a las cebollas",
	"he visto trozos de mi mierda mas bonitos que tu",
	"mira pedazo de hijo de puta, me cago en todos los muertos de tu arbol genealógico y si me apuras tambien en los vivos, puto amorfo de mierda te pillo por la calle y te hundo el pecho a martillazos , enfermo hijo de la gran puta , si tienes hijos espero que tengan alguna discapacidad fisica o mental o en su defecto los atropelle un autobus , pero que no mueran que sufran toda su puta vida y si no tienes hijos nunca que sera lo que pasara seguramente dios te bendiga con una gordaca puto follapinos hijodelagranputa, te voy quitando partes de tu ridiculo cuerpo y me las voy comiendo y mientras me las como las cagare y te haré comer mis putas heces con trozacos de tu piel rebozados y cuando ya te haya destripado completamente y haberte hecho comer toda la mierda que suelte de mi precioso y brillante culo ire a por tu hermana y si no tienes hermana ire a por la sudada de tu puta madre y si voy inspirado ire a por las dos , la secuestrare , las metere en una furgoneta , las llevare a una habitacion , las metere el rabo por todos los agujeros de su cuerpo (si , incluidos los de la nariz y orejas) me corre dentro de ellas y esperare 9 meses a que nazcan sus hijas y cuando cumplan 13 años me las follare tambien y si aun asi despues de eso te siguen quedando primas o tias hare lo mismo con ellas y cuando ya este cansado de follarme a toda tu familia de piojosos cojere unas cuantas cadenas las pondre en mi coche y recorrere 300km con toda la tu familia enganchada a ellas y si despues de eso queda alguien vivo , le hecho alcohol para que rabie aun mas de dolor y despues de todo eso ire al hospital cuando ya te hayas recuperado de el destripamiento que te hice te sacare de hay te llevare a la misma habitacion donde me folle a todas las mujeres de tu actual familia y a las que preceden en tu arbol genialogico y mientras te pongo los videos de como me follaba a tu madre te dare minipollazos en la frente hasta que se te quede la marca de mi grande y devastador glande para el resto de tu vida y asi cada vez que te mires en el espejo recordaras esos videos y lo que hice con tu familia , despues de eso te soltare y volvere a ir a por ti a los tres meses , te volvere a meter en la habitacion , pero esta vez nada suave , esta vez cojere tus manos y empezare a meterte agujas entre las uñas hasta que el nivel de dolor te haga desmayarte y te reanimare con un desfibrilador , te bajare los pantalones y los calzoncillos y empezare a darte minimatillazos en tus cojones hasta que poco a poco se vayan deshaciendo y tu escroto quede completamente vano , imagino que despues de eso te desmayaras otra vez , pues volvere a usar el desfibrilador para reanimarte y metere tus pies en un cubo con agua , te pondre pinzas en los pezones , pene y lengua y te dare descargas hasta que vuelvas a desmayarte , cuando lo hagas ya sabes lo que hare.. y volvere y cojere unas tenazas e ire arrancando una a una tus putas uñas pedazo de escoria , despues te tumbare , te pondre un trapo en la cara e ire hechandote en la boca agua poco a poco sin que llegues a ahogarte ... despues me ire y volvere cada a dia para hacerte una tortura diferente , para que cada vez que oyeras mis pasos acercarse a la puerta a horas diferentes cada dia , un miedo que jamas hayas experimentado recorra tu cuerpo y quedarme en la puerta haciendo como que habro hasta que te mees encima , entonces entrare y comenzare... cuando vea que ya no das para mas torturas te dejare que te cures en un hospital y volvere a ir a por ti cuando te recuperes , te cojere y mientras te quemo los ojos con un soplete te daremartillazos en la nuez hasta que mueras pedazo de hijodelagran puta pero no pienses que todo acaba a hay... si la reencarnacion existe , volvere reencarnado en culaquier otra persona y te hare a ti y a toda tu nueva familia todo lo que te hecho en esta vida pero mas lento y sin matarte para que cada vez que vieses una sombra en la noche pienses que soy yo , que te entre una locura impresionante , que caigas en un estado vegetativo simplemente del miedo que te causa mi presencia"
}

function PLUGIN.action(msg)
	
	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	input = input:gsub("%a", string.upper, 1)
	math.randomseed(os.time())
	local bullying = PLUGIN.bullying[math.random(#PLUGIN.bullying)]
	local phrase = input .. ", " .. bullying
	send_msg(msg, phrase)
end

return PLUGIN
