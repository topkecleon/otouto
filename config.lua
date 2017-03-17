 -- For details on configuration values, see README.md#configuration.
return {

    -- Your authorization token from the botfather. (string, put quotes)
    bot_api_key = nil,
    -- Your Telegram ID (number).
    admin = nil,
    -- Two-letter language code.
    -- Fetches it from the system if available, or defaults to English.
    lang = os.getenv('LANG') and os.getenv('LANG'):sub(1,2) or 'en',
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
    -- Whether luarun should use serpent instead of dkjson for serialization.
    luarun_serpent = false,

    hackernews = {
        -- Interval (in minutes) for hackernews.lua to fetch new posts.
        -- This only triggers when someone runs the command; not as a cron job.
        interval = 60,
        -- Whether hackernews.lua should cache posts at load time.
        on_start = false,
        -- Max number of posts fetched, and number sent in PM.
        private_count = 8,
        -- Number of posts sent in groups.
        group_count = 4
    },

    remind = {
        -- Should reminders be saved if they fail to send?
        persist = false,
        max_length = 1000,
        max_duration = 526000,
        max_reminders_group = 10,
        max_reminders_private = 50
    },

    cleverbot = {
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
        -- Conversation, group, or channel for kick/ban notifications.
        -- Defaults to config.log_chat if left empty.
        log_chat = nil,
        -- Default autoban setting.
        -- A user is banned after being autokicked this many times in a day.
        autoban = 3,
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
        },
        -- Default flag settings.
        flags = {
            -- unlisted
            [1] = false,
            -- antisquig
            [2] = false,
            -- antisquig++
            [3] = false,
            -- antibot
            [4] = false,
            --antiflood
            [5] = false,
            -- antihammer
            [6] = false,
            -- nokicklog
            [7] = false,
            -- antilink
            [8] = false,
            -- modrights
            [9] = false
        }
    },

    plugins = { -- To enable a plugin, add its name to the list.
        'users',
        'end_forwards',
        'blacklist',
        'about',
        'calc',
        'cats',
        'hexcolor',
        'commit',
        'control',
        'currency',
        'dice',
        'echo',
        'eightball',
        'location',
        'hackernews',
        'imdb',
        'me',
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
        -- Add new plugins here.
        'help'
    }

}
