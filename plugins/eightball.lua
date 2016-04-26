local command = '8ball'
local doc = '`Returns an answer from a magic 8-ball!`'

local triggers = {
	'^/8ball',
	'y/n%p?$'
}

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

local action = function(msg)

	local output

	if msg.text_lower:match('y/n%p?$') then
		output = yesno_answers[math.random(#yesno_answers)]
	else
		output = ball_answers[math.random(#ball_answers)]
	end

	sendReply(msg, output)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
