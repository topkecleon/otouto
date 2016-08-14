 -- For details on configuration values, see README.md#configuration.
return {

    -- Your authorization token from the botfather.
    bot_api_key = nil,
    -- Your Telegram ID.
    admin = nil,
    -- Two-letter language code.
    lang = 'en',
    -- The channel, group, or user to send error reports to.
    -- If this is not set, errors will be printed to the console.
    log_chat = nil,
    -- The port used to communicate with tg for administration.lua.
    -- If you change this, make sure you also modify launch-tg.sh.
    cli_port = 4567,
    -- The symbol that starts a command. Usually noted as '/' in documentation.
    cmd_pat = '/',
    -- If drua is used, should a user be blocked when he's blacklisted?
    drua_block_on_blacklist = false,
    -- The filename of the database. If left nil, defaults to $username.db.
    database_name = nil,
    -- The block of text returned by /start and /about..
    about_text = [[
I am otouto, the plugin-wielding, multipurpose Telegram bot.

Send /help to get started.
    ]],

    errors = { -- Generic error messages.
        generic = 'An unexpected error occurred.',
        connection = 'Connection error.',
        results = 'No results found.',
        argument = 'Invalid argument.',
        syntax = 'Invalid syntax.'
    },

    -- https://datamarket.azure.com/dataset/bing/search
    bing_api_key = nil,
    -- http://console.developers.google.com
    google_api_key = nil,
    -- https://cse.google.com/cse
    google_cse_key = nil,
    -- http://openweathermap.org/appid
    owm_api_key = nil,
    -- http://last.fm/api
    lastfm_api_key = nil,
    -- http://api.biblia.com
    biblia_api_key = nil,
    -- http://thecatapi.com/docs.html
    thecatapi_key = nil,
    -- http://api.nasa.gov
    nasa_api_key = nil,
    -- http://tech.yandex.com/keys/get
    yandex_key = nil,
    -- Interval (in minutes) for hackernews.lua to update.
    hackernews_interval = 60,
    -- Whether hackernews.lua should update at load/reload.
    hackernews_onstart = false,
    -- Whether luarun should use serpent instead of dkjson for serialization.
    luarun_serpent = false,

    remind = {
        persist = true,
        max_length = 1000,
        max_duration = 526000,
        max_reminders_group = 10,
        max_reminders_private = 50
    },

    chatter = {
        cleverbot_api = 'https://brawlbot.tk/apis/chatter-bot-api/cleverbot.php?text=',
        connection = 'I don\'t feel like talking right now.',
        response = 'I don\'t know what to say to that.'
    },

    greetings = {
        ["Hello, #NAME."] = {
            "hello",
            "hey",
            "hi",
            "good morning",
            "good day",
            "good afternoon",
            "good evening"
        },
        ["Goodbye, #NAME."] = {
            "good%-?bye",
            "bye",
            "later",
            "see ya",
            "good night"
        },
        ["Welcome back, #NAME."] = {
            "i'm home",
            "i'm back"
        },
        ["You're welcome, #NAME."] = {
            "thanks",
            "thank you"
        }
    },

    reactions = {
        ['shrug'] = '¯\\_(ツ)_/¯',
        ['lenny'] = '( ͡° ͜ʖ ͡°)',
        ['flip'] = '(╯°□°）╯︵ ┻━┻',
        ['look'] = 'ಠ_ಠ',
        ['shots'] = 'SHOTS FIRED',
        ['facepalm'] = '(－‸ლ)'
    },

    administration = {
        -- Whether moderators can set a group's message of the day.
        moderator_setmotd = false,
        -- Default antiflood values.
        antiflood = {
            text = 5,
            voice = 5,
            audio = 5,
            contact = 5,
            photo = 10,
            video = 10,
            location = 10,
            document = 10,
            sticker = 20
        }
    },

    plugins = { -- To enable a plugin, add its name to the list.
        'about',
        'blacklist',
        'calc',
        'cats',
        'commit',
        'control',
        'currency',
        'dice',
        'echo',
        'eightball',
        'gMaps',
        'hackernews',
        'imdb',
        'nick',
        'ping',
        'pun',
        'reddit',
        'shout',
        'slap',
        'time',
        'urbandictionary',
        'whoami',
        'wikipedia',
        'xkcd',
        -- Put new plugins above this line.
        'help',
        'greetings'
    }

}
