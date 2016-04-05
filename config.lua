return {

	-- Your authorization token from the botfather.
	bot_api_key = '',
	-- Differences, in seconds, between your time and UTC.
	time_offset = 0,
	-- Two-letter language code.
	lang = 'en',
	-- Your Telegram ID.
	admin = 00000000,
	-- The channel, group, or user to send error reports to.
	-- If this is not set, errors will be printed to the console.
	log_chat = nil,
	-- The port used to communicate with tg for administration.lua.
	-- If you change this, make sure you also modify launch-tg.sh.
	cli_port = 4567,
	-- The block of text returned by /start.
	about_text = [[
I am otouto, the plugin-wielding, multipurpose Telegram bot.

Send /help to get started.
	]],

	-- http://console.developers.google.com
	google_api_key = '',
	-- https://cse.google.com/cse
	google_cse_key = '',
	-- http://openweathermap.org/appid
	owm_api_key = '',
	-- http://last.fm/api
	lastfm_api_key = '',
	-- http://api.biblia.com
	biblia_api_key = '',
	-- http://thecatapi.com/docs.html
	thecatapi_key = '',
	-- http://api.nasa.gov
	nasa_api_key = '',
	-- http://tech.yandex.com/keys/get/?service=trnsl
	yandex_key = '',
	-- http://developer.simsimi.com/signUp
	simsimi_key = '',
	simsimi_trial = true,

	errors = {
		connection = 'Connection error.',
		results = 'No results found.',
		argument = 'Invalid argument.',
		syntax = 'Invalid syntax.',
		chatter_connection = 'I don\'t feel like talking right now.',
		chatter_response = 'I don\'t know what to say to that.'
	},

	plugins = {
		'control.lua',
		'blacklist.lua',
		'about.lua',
		'ping.lua',
		'whoami.lua',
		'nick.lua',
		'echo.lua',
		'gSearch.lua',
		'gImages.lua',
		'gMaps.lua',
		'youtube.lua',
		'wikipedia.lua',
		'hackernews.lua',
		'imdb.lua',
		'calc.lua',
		'urbandictionary.lua',
		'time.lua',
		'eightball.lua',
		'reactions.lua',
		'dice.lua',
		'reddit.lua',
		'xkcd.lua',
		'slap.lua',
		'commit.lua',
		'pun.lua',
		'pokedex.lua',
		'bandersnatch.lua',
		'currency.lua',
		'cats.lua',
		'hearthstone.lua',
		'shout.lua',
		'apod.lua',
		'patterns.lua',
		-- Put new plugins above this line.
		'help.lua',
		'greetings.lua'
	}

}
