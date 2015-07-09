local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('8ball.COMMAND') .. '\n' .. I18N('8ball.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'helix',
	'^' .. config.COMMAND_START .. I18N('8ball.COMMAND'),
	'y/n%p?$'
}

PLUGIN.answers = {
	"It is certain.",
	"It is decidedly so.",
	"Without a doubt.",
	"Yes, definitely.",
	"You may rely on it.",
	"As I see it, yes.",
	"Most likely.",
	"Outlook: good.",
	"Yes.",
	"Signs point to yes.",
	"Reply hazy try again.",
	"Ask again later.",
	"Better not tell you now.",
	"Cannot predict now.",
	"Concentrate and ask again.",
	"Don't count on it.",
	"My reply is no.",
	"My sources say no.",
	"Outlook: not so good.",
	"Very doubtful.",
	"There is a time and place for everything, but not now."
}

PLUGIN.yesno = {'Absolutely.', 'In your dreams.', 'Yes.', 'No.', 'Maybe.'}

function PLUGIN.action(msg)

	math.randomseed(os.time())

	if string.match(string.lower(msg.text), 'y/n') then
		message = PLUGIN.yesno[math.random(#PLUGIN.yesno)]
	else
		message = PLUGIN.answers[math.random(#PLUGIN.answers)]
	end

  send_msg(msg, message)

end

return PLUGIN
