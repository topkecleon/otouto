 -- For details on configuration values, see README.md#configuration.
return {

    -- Your authorization token from the botfather. (string, put quotes)
    bot_api_key = os.getenv('OTOUTO_BOT_API_KEY'),
    -- Your Telegram ID (number).
    admin = os.getenv('ADMIN_ID'),
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
Based on otouto by topkecleon.
    ]],

    errors = { -- Generic error messages.
        generic = 'An unexpected error occurred.',
        connection = 'Connection error.',
        results = 'No results found.',
        argument = 'Invalid argument.',
        syntax = 'Invalid syntax.',
        specify_targets = 'Specify a target or targets by reply, username, or ID.',
        specify_target  = 'Specify a target by reply, username, or ID.'
    },
    
    -- Whether luarun should use serpent instead of dkjson for serialization.
    luarun_serpent = false,

    administration = {
        -- Conversation, group, or channel for kick/ban notifications.
        -- Defaults to config.log_chat if left empty.
        log_chat = nil,
        -- link or username
        log_chat_link = nil,
        -- Default autoban setting.
        -- A user is banned after being autokicked this many times in a day.
        autoban = 3,
        -- Default flag settings.
        flags = {
            private = true,
            antisquig = true,
            antibot = true,
            antilink = true
        }
    },

    plugins = { -- To enable a plugin, add its name to the list.
        'control',
        'luarun',
        'users',
        'banremover',
        'autopromoter',
        'filterer',
        'flags',
        'antilink',
        'antisquig',
        'antisquigpp',
        'antibot',
        'nostickers',
        'addgroup',
        'removegroup',
        'listgroups',
        'listadmins',
        'listmods',
        'listrules',
        'getlink',
        'regenlink',
        'automoderation',
        'antihammer_whitelist',
        'setrules',
        'kickme',
        'automoderation',
        'addmod',
        'demod',
        'setgovernor',
        'mute',
        'unrestrict',
        'hammer',
        'unhammer',
        'ban',
        'kick',
        'filter',
        'description',
        'setdescription',
        'addadmin',
        'deadmin',
        'fixperms',
        'help'
    }

}
