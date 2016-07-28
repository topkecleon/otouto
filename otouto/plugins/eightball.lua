local eightball = {}

local utilities = require('otouto.utilities')

eightball.command = '8ball'
eightball.doc = 'Returns an answer from a magic 8-ball!'

function eightball:init(config)
	eightball.triggers = utilities.triggers(self.info.username, config.cmd_pat,
		{'[Yy]/[Nn]%p*$'}):t('8ball', true).table
end

local ball_answers = {
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

local yesno_answers = {
	'Absolutely.',
	'In your dreams.',
	'Yes.',
	'No.'
}

local yes_answers = {
	'Absolutely.',
	'Yes.'
}

local no_answers = {
	'In your dreams.',
	'No.'
}

function eightball:action(msg)

	local output

	if msg.text:match('y/n%p?$') or msg.text:match('Y/N%p?$') then
		output = yesno_answers[math.random(#yesno_answers)]
	elseif msg.text:match('Y/n%p?$') then
		output = yes_answers[math.random(#yes_answers)]
	elseif msg.text:match('y/N%p?$') then
		output = no_answers[math.random(#no_answers)]
	else
		output = ball_answers[math.random(#ball_answers)]
	end

	utilities.send_reply(self, msg, output)

end

return eightball
