# otouto
The plugin-wielding, multipurpose Telegram bot.

[Public Bot](http://telegram.me/mokubot) |
[Official Channel](http://telegram.me/otouto) |
[Bot Development Group](http://telegram.me/BotDevelopment)

otouto is a plugin-based, IRC-style bot written in Lua for the
[Telegram Bot API](http://core.telegram.org/bots/api).

otouto (including all plugins and documentation) is free software; you are free
to redistribute it and/or modify it under the terms of the GNU Affero General
Public License, version 3. See **LICENSE** for details.

**The Manual**

| For Users                                     | For Coders                    |
|:----------------------------------------------|:------------------------------|
| [Setup](#setup)                               | [Plugins](#plugins)           |
| [Configuration](#configuration)               | [Bindings](#bindings)         |
| [Control plugins](#control-plugins)           | [Database](#database)         |
| [Group administration](#group-administration) | [Output style](#output-style) |
| [List of plugins](#list-of-plugins)           | [Contributors](#contributors) |

## Setup
To get your bot running as soon as possible, see [Quick start](#quick-start).

otouto uses Lua (5.3 is recommended) and the following Lua libraries: luasocket,
luasec, multipart-post, dkjson, and lpeg. If you are using Lua 5.2, luautf8 is
also required. It is recommended you install these with Luarocks. This can be
done easily on Ubuntu with the `install-dependencies.sh` script.

To get started, clone the repository and set the following values in
`config.lua`:

 - `bot_api_key` as your bot authentication token from the BotFather.
 - `admin` as your Telegram ID.

Some plugins are not enabled by default. If you wish to enable them, add their
names (sans file extension) to the `plugins` table in the configuration file.

When you are ready to start the bot, run the `launch.sh` script. This script
will automatically restart the bot five seconds after being stopped. If this
behavior is undesired, start the bot manually with `lua main.lua`.

To stop the bot, send "/halt" through Telegram. You can exit with Ctrl-C (or two
Ctrl-C if using `launch.sh`), but this is not recommended as it risks data loss.

Note that certain plugins, such as `translate.lua` and `greetings.lua`, will
require privacy mode to be disabled. Additionally, some plugins may require or
make use of various API keys and/or other configuration values not set by
default. See [Configuration](#configuration) for details.

### Quick start
1. Clone the repository.
`git clone http://otou.to/code otouto`
2. Install dependencies: Lua and the following Lua libs: luasocket, luasec,
multipart-post, dkjson, and lpeg.†
3. Add your bot token and Telegram ID to `config.lua`.
4. Start the bot with `./launch.sh`.

**†** On Ubuntu, this can be done easily with the `install-dependencies.sh`
script.

## Configuration
otouto is configured in the `config.lua` file. It is the single point of
configuration for the bot, and contains any necessary user-specific variables,
such as API keys, custom error messages, and enabled plugins.

This section includes an exhaustive list of possible configuration values for
otouto and official plugins.

### Bot configuration values

| Name          | Default | Description                                        |
|:--------------|:--------|:---------------------------------------------------|
| `bot_api_key` | nil     | Telegram bot API token.                            |
| `admin`       | nil     | Telegram ID of the bot owner.                      |
| `log_chat`    | nil     | Telegram ID of the recipient for error messages.   |
| `cmd_pat`     | `"/"`   | Character (or string) to be used for bot commands. |
| `lang`        | `"en"`  | Two-letter ISO 639-1 language code.                |
| `about_text`  | ...     | Informational text to be returned by /about.       |

#### Error messages
These are the generic error messages used by most plugins. These belong in a
table named `errors`.

| Name         | Default                           |
|:-------------|:----------------------------------|
| `generic`    | `"An unexpected error occurred."` |
| `connection` | `"Connection error."`             |
| `results`    | `"No results found."`             |
| `argument`   | `"Invalid argument."`             |
| `syntax`     | `"Invalid syntax."`               |

#### Plugins table
This table is an array of the names of enabled plugins. To enable a plugin, add
its name to the list.

### Plugin configuration values

| Name                      | Description
|:--------------------------|:--------------------------------------------------------------------------------------------------|
| `google_api_key`          | [Google API](http://console.developers.google.com) key for `google_images.lua` and `youtube.lua`. |
| `google_cse_key`          | [Google CSE](http://cse.google.com/cse) key for `google_images.lua`.                              |
| `lastfm_api_key`          | [last.fm API](http://last.fm/api) key for `lastfm.lua`.                                           |
| `owm_api_key`             | [OpenWeatherMap API](http://openweathermap.org/API) key for `weather.lua`.                        |
| `biblia_api_key`          | [Biblia API](http://api.biblia.com) key for `bible.lua`.                                          |
| `thecatapi_key`           | [The Cat API](http://thecatapi.com) key for `cats.lua` (optional).                                |
| `nasa_api_key`            | [NASA API](http://api.nasa.gov) key for the `apod.lua` (optional).                                |
| `yandex_key`              | [Yandex API](http://tech.yandex.com/keys/get) key for `translate.lua`.                            |
| `bing_api_key`            | [Bing Search API](http://datamarket.azure.com/dataset/bing/search) key for `bing.lua`.            |
| `drua_block_on_blacklist` | Whether to block blacklisted users, if tg-cli is in use.                                          |
| `cli_port`                | The port to use for tg connections.                                                               |
| `hackernews_interval`     | The lifespan, in minutes, for each set of results hackernews.lua before refreshing.               |
| `hackernews_onstart`      | Whether hackernews.lua should fetch articles at load (rather than waiting for demand).            |

Some plugins have many configuration values which warrant their own section of
the configuration file. That section will be the name of the plugin, without the
file extension. They are listed below.

### hackernews.lua

| Name            | Default | Description                                     |
|:----------------|:--------|:------------------------------------------------|
| `interval`      | `60`    | The time, in minutes, between refetching links. |
| `on_start`      | `false` | Whether to fetch links at load time.            |
| `private_count` | `8`     | Number of links sent in private messages.       |
| `group_count`   | `4`     | Number of links sent in group chats.            |

#### remind.lua

| Name                    | Default  | Description                                              |
|:------------------------|:---------|:---------------------------------------------------------|
| `persist`               | `true`   | Whether reminders should be saved if they fail for send. |
| `max_length`            | `1000`   | The maximum length for reminders, in bytes.              |
| `max_duration`          | `526000` | The maximum duration of a reminder, in minutes.          |
| `max_reminders_group`   | `10`     | The maximum number of reminders for a group.             |
| `max_reminders_private` | `50`     | The maximum number of reminders in private.              |

#### chatter.lua

| Name            | Default                                    | Description                                                              |
|:----------------|:-------------------------------------------|:-------------------------------------------------------------------------|
| `cleverbot_api` | `"https://brawlbot.tk/apis/chatter-bot-api/cleverbot.php?text="` | Cleverbot API endpoint used by `cleverbot.lua`.    |
| `connection`    | `"I don't feel like talking right now."`                         | Generic response for connection errors.            |
| `response`      | `"I don't know what to say to that."`                            | Generic response for when the API has no response. |

#### greetings.lua
The `greetings` table is a list of custom responses for the greetings plugin.
Each value is an array of triggers, and the key for that array is the response.
The default values are inserted by the greetings plugin if there is no user
configuration. In the responses, `#NAME` is replaced with the user's name or
nickname. The bot's name is automatically appended to all triggers. Triggers are
not case sensitive.

#### reactions.lua
The `reactions` table is also a list of custom responses, for the reactions
plugin. Each value is a key/value pair, where the key is the trigger, and the
value is the reaction. The reactions plugin differs from the greetings plugin by
how it is triggered: A reaction command must be at the beginning or end of a
line. Reactions may be formatted with HTML. Configuration values should be
pre-escaped.

#### eightball.lua
The `eightball` table is an array of custom responses for the eightball plugin.

## Control plugins
Some plugins are designed to be used by the bot's owner. Here are some examples,
how they're used, and what they do.

| Plugin          | Command    | Function                                           |
|:----------------|:-----------|:---------------------------------------------------|
| `control.lua`   | /reload    | Reloads all plugins and configuration.             |
|                 | /halt      | Shuts down the bot after saving the database.      |
|                 | /script    | Runs a list a bot commands, separated by newlines. |
| `blacklist.lua` | /blacklist | Blocks people from using the bot.                  |
| `shell.lua`     | /run       | Executes shell commands on the host system.        |
| `luarun.lua`    | /lua       | Executes Lua commands in the bot's environment.    |

## Group Administration
The administration plugin enables self-hosted, single-realm group
administration, supporting both normal groups and supergroups whch are owned by
the bot owner. This works by sending TCP commands to an instance of tg running
on the owner's account.

To get started, compile the `test` branch of
[tg-cli](http://github.com/vysheng/tg). On Ubuntu and Debian, this can be done
easily with the `tg-install.sh` script.

Once the compilation is finished, enable the `administration` plugin in your
config file. You may have reason to change the default TCP port (4567); if that
is the case, remember to change it in `tg-launch.sh` as well. Run
`./tg-launch.sh` in a separate screen/tmux window. You'll have to enter your
phone number and go through the login process the first time. The script is set
to restart tg after two seconds, so you'll need to Ctrl+C after exiting.

While tg is running, you may start/reload otouto with `administration.lua`
enabled, and have access to a wide variety of administrative commands and
automata. The administration "database" is stored in `administration.json`. To
start using otouto to administrate a group (note that you must be the owner (or
an administrator)), send `/gadd` to that group. For a list of commands, use
`/ahelp`. Below I'll describe various functions now available to you.

| Command     | Function                                         | Privilege | Internal? |
|:------------|:-------------------------------------------------|:----------|:----------|
| /groups     | Returns a list of administrated groups (except the unlisted).   | 1  | N |
| /ahelp      | Returns a list of accessible administrative commands.           | 1  | Y |
| /ops        | Returns a list of the moderators and governor of a group.       | 1  | Y |
| /desc       | Returns detailed information for a group.                       | 1  | Y |
| /rules      | Returns the rules of a group.                                   | 1  | Y |
| /motd       | Returns the message of the day of a group.                      | 1  | Y |
| /link       | Returns the link for a group.                                   | 1  | Y |
| /kick       | Removes the target from the group.                              | 2  | Y |
| /ban        | Bans the target from the group.                                 | 2  | Y |
| /unban      | Unbans the target from the group.                               | 2  | Y |
| /filter     | Configures trigger-terms for autokicks.                         | 2† | Y |
| /setmotd    | Sets the message of the day for a group.                        | 2† | Y |
| /changerule | Changes an individual group rule.                               | 3  | Y |
| /setrules   | Sets the rules for a group.                                     | 3  | Y |
| /setlink    | Sets the link for a group.                                      | 3  | Y |
| /alist      | Returns a list of administrators.                               | 3  | Y |
| /flags      | Returns a list of flags and their states, or toggles one.       | 3  | Y |
| /antiflood  | Configures antiflood (flag 5) settings.                         | 3  | Y |
| /mod        | Promotes a user to a moderator.                                 | 3  | Y |
| /demod      | Demotes a moderator to a user.                                  | 3  | Y |
| /gov        | Promotes a user to the governor.                                | 4  | Y |
| /degov      | Demotes the governor to a user.                                 | 4  | Y |
| /hammer     | Blacklists and globally bans a user.                            | 4  | N |
| /unhammer   | Unblacklists and globally bans a user.                          | 4  | N |
| /admin      | Promotes a user to an administrator.                            | 5  | N |
| /deadmin    | Demotes an administrator to a user.                             | 5  | N |
| /gadd       | Adds a group to the administrative system.                      | 5  | N |
| /grem       | Removes a group from the administrative system.                 | 5  | Y |
| /glist      | Returns a list of all administrated groups and their governors. | 5  | N |

**†** Moderators may only use these commands if the modrights flag is enabled.

Internal commands can only be run within an administrated group.

### Description of Privileges

|   | Title         | Description                                                       | Scope  |
|:-:|:--------------|:------------------------------------------------------------------|:-------|
| 0 | Banned        | Cannot enter the group(s).                                        | Either |
| 1 | User          | Default rank.                                                     | Local  |
| 2 | Moderator     | Can kick/ban/unban users. Can set MOTD.                           | Local  |
| 3 | Governor      | Can set rules/link, promote/demote moderators, modify flags.      | Local  |
| 4 | Administrator | Can globally ban/unban users, promote/demote governors.           | Global |
| 5 | Owner         | Can add/remove groups, broadcast, promote/demote administrators.  | Global |

Obviously, each greater rank inherits the privileges of the lower, positive
ranks.

### Flags

|   | Name        | Description                                                                      |
|:-:|:------------|:---------------------------------------------------------------------------------|
| 1 | unlisted    | Removes a group from the /groups listing.                                        |
| 2 | antisquig   | Automatically removes users for posting Arabic script or RTL characters.         |
| 3 | antisquig++ | Automatically removes users whose names contain Arabic script or RTL characters. |
| 4 | antibot     | Prevents bots from being added by non-moderators.                                |
| 5 | antiflood   | Prevents flooding by rate-limiting messages per user.                            |
| 6 | antihammer  | Allows globally-banned users to enter a group.                                   |
| 7 | nokicklog   | Prevents kick and ban notifications from appearing in the designated kick log.   |
| 8 | antilink    | Automatically removes users for posting external group links.                    |
| 9 | modrights   | Allows moderators to set a group's title, photo, motd, and link.                 |

#### antiflood
antiflood (flag 5) provides a system of automatic flood protection by removing
users who post too much. It is entirely configurable by a group's governor, an
administrator, or the bot owner. For each message to a particular group, a user
is awarded a certain number of "points". The number of points is different for
each message type. When the user reaches 100 points, he is removed. Points are
reset each minute. In this way, if a user posts twenty messages within one
minute, he is removed.

**Default antiflood values:**

| Type | Points |
|:-----|:------:|
| text     | 5  |
| contact  | 5  |
| audio    | 5  |
| voice    | 5  |
| photo    | 10 |
| document | 10 |
| location | 10 |
| video    | 10 |
| sticker  | 20 |

Additionally, antiflood can be configured to automatically ban a user after he
has been automatically kicked from a single group a certain number of times in
one day. This is configurable as the antiflood value `autoban` and is set to
three by default.

## List of plugins

| Plugin                | Command                       | Function                                                  | Aliases |
|:----------------------|:------------------------------|:----------------------------------------------------------|:--------|
| `help.lua`            | /help [command]               | Returns a list of commands or command-specific help.         | /h   |
| `about.lua`           | /about                        | Returns the about text as configured in config.lua.                 |
| `ping.lua`            | /ping                         | The simplest plugin ever!                                           |
| `echo.lua`            | /echo ‹text›                  | Repeats a string of text.                                           |
| `bing.lua`            | /bing ‹query›                 | Returns Bing web results.                                    | /g   |
| `google_images.lua`   | /images ‹query›               | Returns a Google image result.                               | /i   |
| `location.lua`        | /location ‹query›             | Returns location data from Google Maps.                      | /loc |
| `youtube.lua`         | /youtube ‹query›              | Returns the top video result from YouTube.                   | /yt  |
| `wikipedia.lua`       | /wikipedia ‹query›            | Returns the summary of a Wikipedia article.                  | /w   |
| `lastfm.lua`          | /np [username]                | Returns the song you are currently listening to.                    |
| `lastfm.lua`          | /fmset [username]             | Sets your username for /np. /fmset -- will delete it.               |
| `hackernews.lua`      | /hackernews                   | Returns the latest posts from Hacker News.                   | /hn  |
| `imdb.lua`            | /imdb ‹query›                 | Returns film information from IMDb.                                 |
| `hearthstone.lua`     | /hearthstone ‹query›          | Returns data for Hearthstone cards matching the query.       | /hs  |
| `calc.lua`            | /calc ‹expression›            | Returns conversions and solutions to math expressions.              |
| `bible.lua`           | /bible ‹reference›            | Returns a Bible verse.                                       | /b   |
| `urbandictionary.lua` | /urban ‹query›                | Returns the top definition from Urban Dictionary.            | /ud  |
| `time.lua`            | /time ‹query›                 | Returns the time, date, and a timezone for a location.              |
| `weather.lua`         | /weather ‹query›              | Returns current weather conditions for a given location.            |
| `nick.lua`            | /nick ‹nickname›              | Set your nickname. /nick - will delete it.                          |
| `whoami.lua`          | /whoami                       | Returns user and chat info for you or the replied-to user.   | /who |
| `eightball.lua`       | /8ball                        | Returns an answer from a magic 8-ball.                              |
| `dice.lua`            | /roll ‹nDr›                   | Returns RNG dice rolls. Uses D&D notation.                          |
| `reddit.lua`          | /reddit [r/subreddit ¦ query] | Returns the top results from a subreddit, query, or r/all.   | /r   |
| `xkcd.lua`            | /xkcd [query]                 | Returns an xkcd strip and its alt text.                             |
| `slap.lua`            | /slap ‹target›                | Gives someone a slap (or worse).                                    |
| `commit.lua`          | /commit                       | Returns a commit message from whatthecommit.com.                    |
| `fortune.lua`         | /fortune                      | Returns a UNIX fortune.                                             |
| `pun.lua`             | /pun                          | Returns a pun.                                                      |
| `pokedex.lua`         | /pokedex ‹query›              | Returns a Pokedex entry.                                     | /dex |
| `currency.lua`        | /cash [amount] ‹cur› to ‹cur› | Converts one currency to another.                                   |
| `cats.lua`            | /cat                          | Returns a cat picture.                                              |
| `reactions.lua`       | /reactions                    | Returns a list of emoticons which can be posted by the bot.         |
| `apod.lua`            | /apod [date]                  | Returns the NASA Astronomy Picture of the Day.                      |
| `dilbert.lua`         | /dilbert [date]               | Returns a Dilbert strip.                                            |
| `regex.lua`           | /s/‹from›/‹to›/               | Search-and-replace using PCRE regexes.                              |
| `remind.lua`          | /remind ‹duration› ‹message›  | Reminds a user of something after a duration of minutes.            |
| `channel.lua`         | /ch ‹channel› \n ‹message›    | Sends a markdown-enabled message to a channel.                      |
| `isup.lua`            | /isup ‹url›                   | Returns the status of a website.                                    |
| `starwars-crawl.lua`  | /sw ‹title ¦ number›          | Returns the opening crawl from the specified Star Wars film. | /sw  |
| `chuckfact.lua`       | /chuck                        | Returns a fact about Chuck Norris.                           | /cn  |
| `catfact.lua`         | /catfact                      | Returns a fact about cats.                                          |
| `wait.lua`            | /wait ‹duration› ‹command›    | Runs a given command after a given span of minutes.                 |

## Plugins
otouto uses a robust plugin system, similar to yagop's
[Telegram-Bot](http://github.com/yagop/telegram-bot).

Most plugins are intended for public use, but a few are for other purposes, like
those for [use by the bot's owner](#control-plugins). See
[here](#list-of-plugins) for a list of plugins.

A list of standard plugin components:

| Component   | Description                                                    |
|:------------|:---------------------------------------------------------------|
| `name`      | Name of the plugin. Matches filename.                          |
| `action`    | Main function. Expects `msg` table as an argument.             |
| `triggers`  | Table of triggers for the plugin. Uses Lua patterns.           |
| `init`      | Optional function run when the plugin is loaded.               |
| `cron`      | Optional function to be called every minute.                   |
| `command`   | Basic command and syntax. Listed in the help text.             |
| `doc`       | Usage for the plugin. Returned by "/help $command".            |
| `error`     | Plugin-specific error message; false for no message.           |
| `help_word` | Keyword for command-specific help. Generated if absent.        |


No component is required, but some depend on others. For example, `action` will
never be run if there's no `triggers`, and `doc` will never be seen if there's
no `command`.

If a plugin's `action` returns `true`, `on_message` will continue its loop.

When an action or cron function fails, the exception is caught and passed to the
`handle_exception` utilty and is either printed to the console or send to the
chat/channel defined in `log_chat` in config.lua.

Interactions with the bot API are straightforward. See the
[Bindings section](#bindings) for details.

Several functions used in multiple plugins are defined in utilities.lua. Refer
to that file for usage and documentation.

## Bindings
Calls to the Telegram bot API are performed with the `bindings.lua` file through
the multipart-post library. otouto's bindings file supports all standard API
methods and all arguments. Its main function, `bindings.request`, accepts three
arguments: `method`, `parameters`, `file`. Before using it, initialize the
bindings module with its `init` function, passing your bot token as the
argument.

`method` is the name of the API method. `parameters` (optional) is a table of
key/value pairs of the method's parameters to be sent with the method. `file`
(super optional) is a table of a single key/value pair, where the key is the
name of the parameter and the value is the filename (if these are included in
`parameters` instead, otouto will attempt to send the filename as a file ID).

Additionally, any method can be called as a key in the `bindings` table
(for example, `bindings.getMe`). The `bindings.gen` function (which is also the
`__index` function in its metatable) will forward its arguments to
`bindings.request` in their proper form. In this way, the following two function
calls are equivalent:

```lua
bindings.request(
    'sendMessage',
    {
        chat_id = 987654321,
        text = 'Quick brown fox.',
        reply_to_message_id = 54321,
        disable_web_page_preview = false,
        parse_mode = 'Markdown'
    }
)

bindings.sendMessage{
    chat_id = 987654321,
    text = 'Quick brown fox.',
    reply_to_message_id = 54321,
    disable_web_page_preview = false,
    parse_mode = 'Markdown'
}
```

Furthermore, `utilities.lua` provides two "shortcut" functions to mimic the
behavior of otouto's old bindings: `send_message` and `send_reply`.
`send_message` accepts these arguments: `self`, `chat_id`, `text`,
`disable_web_page_preview`, `reply_to_message_id`, `use_markdown`. The following
function call is equivalent to the two above:

```lua
utilities.send_message(987654321, 'Quick brown fox.', false, 54321, true)
```

Uploading a file for the `sendPhoto` method would look like this:

```lua
bindings.sendPhoto({ chat_id = 987654321 }, { photo = 'dankmeme.jpg' } )
```

and using `sendPhoto` with a file ID would look like this:

```lua
bindings.sendPhoto{
    chat_id = 987654321,
    photo = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'
}
```

Upon success, bindings will return the deserialized result from the API. Upon
failure, it will return false and the result. In the case of a connection error,
it will return two false values. If an invalid method name is given, bindings
will throw an exception. This is to mimic the behavior of more conventional
bindings as well as to prevent "silent errors".

## Database
otouto doesn't use one. This isn't because of dedication to lightweightedness or
some clever design choice. Interfacing with databases through Lua is never a
simple, easy-to-learn process. As one of the goals of otouto is that it should
be a bot which is easy to write plugins for, our approach to storing data is to
treat our datastore like any ordinary Lua data structure. The "database" is a
table accessible in the `database` value of the bot instance (usually
`self.database`), and is saved as a JSON-encoded plaintext file each hour, or
when the bot is told to halt. This way, keeping and interacting with persistent
data is no different than interacting with a Lua table -- with one exception:
Keys in tables used as associative arrays must not be numbers. If the index keys
are too sparse, the JSON encoder/decoder will either change them to keys or
throw an error.

Alone, the database will have this structure:

```lua
{
    users = {
        ["55994550"] = {
            id = 55994550,
            first_name = "Drew",
            username = "topkecleon"
        }
    },
    userdata = {
        ["55994550"] = {
            nickname = "Worst coder ever",
            lastfm = "topkecleon"
        }
    },
    version = "3.11"
}
```

`database.users` will store user information (usernames, IDs, etc) when the bot
sees the user. Each table's key is the user's ID as a string.

`database.userdata` is meant to store miscellanea from various plugins.

`database.version` stores the last bot version that used it. This is to simplify
migration to the next version of the bot an easy, automatic process.

Data from other plugins is usually saved in a table with the same name of that
plugin. For example, administration.lua stores data in
`database.administration`.

## Output style
otouto plugins should maintain a consistent visual style in their output. This
provides a recognizable and comfortable user experience.

### Titles
Title lines should be **bold**, including any names and trailing punctuation
(such as colons). The exception to this rule is if the title line includes a
query, which should be _italic_. It is also acceptable to have a link somewhere
inside a title, usually within parentheses. eg:

> **Star Wars: Episode IV - A New Hope (1977)**
>
> **Search results for** _star wars_**:**
>
> **Changelog for otouto (**[Github](http://github.com/topkecleon/otouto)**):**

### Lists
Numerated lists should be done with the number and its following punctuation
bolded. Unnumbered lists should use the bullet character ( • ). eg:

> **1.** Life as a quick brown fox.
>
> **2.** The art of jumping over lazy dogs.

and

> • Life as a quick brown fox.
>
> • The art of jumping over lazy dogs.

### Links
Always name your links. Even then, use them with discretion. Excessive links
make a post look messy. Links are reasonable when a user may want to learn more
about something, but should be avoided when all desirable information is
provided. One appropriate use of linking is to provide a preview of an image, as
xkcd.lua and apod.lua do.

### Other Stuff
User IDs should appear within brackets, monospaced (`[123456789]`). Descriptions
and information should be in plain text, but "flavor" text should be italic. The
standard size for arbitrary lists (such as search results) is eight within a
private conversation and four elsewhere. This is a trivial pair of numbers
(leftover from the deprecated Google search API), but consistency is noticeable
and desirable.

## Contributors
Everybody is free to contribute to otouto. The most direct way of doing this is
to fork and start making pull requests. If you have an idea and are not sure how
to implement it, feel free to open an issue.

The creator and maintainer of otouto is
[topkecleon](https://telegram.me/topkecleon). A list of contributors can be
found [here](http://github.com/topkecleon/otouto/graphs/contributors).

If code or ideas aren't your thing, the project does accept monetary
contributions. Bitcoin donations are accepted at the following address:
`1GJGke82JthhcEcpgnC9qNp7B4sfsGsQSN`.

Here's a list of donors:

| Donators (in chronological order)             |
|:----------------------------------------------|
| [n8 c00](http://telegram.me/n8_c00)           |
| [Alex](http://telegram.me/sandu)              |
| [Brayden](http://telegram.me/bb010g)          |
| [Milad](http://telegram.me/thelad)            |
