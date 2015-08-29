local PLUGIN = {}

PLUGIN.doc = [[
	/8ball
	Magic 8-ball. Returns a standard 8ball message, unless called with "y/n", where it will return a less verbose answer.
]]

PLUGIN.triggers = {
	'^/helix',
	'^/8ball',
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

PLUGIN.yesno = {'Absolutely.', 'In your dreams.', 'Yes.', 'No.'}

function PLUGIN.action(msg)

	math.randomseed(os.time())

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	if string.match(string.lower(msg.text), 'y/n') then
		message = PLUGIN.yesno[math.random(#PLUGIN.yesno)]
	else
		message = PLUGIN.answers[math.random(#PLUGIN.answers)]
	end

  send_msg(msg, message)

end

return PLUGIN
