#otouto
The plugin-wielding, multipurpose Telegram bot.

The public bot runs on [@mokubot](https://telegram.me/mokubot).

otouto is licensed under the GNU General Public License. A copy of the license has been included in [LICENSE](https://github.com/topkecleon/otouto/blob/master/LICENSE).

##What is it?
otouto is an independently developed Telegram API bot written in Lua. Originally conceived as a tg-cli script in February of 2015, otouto has since been migrated to the API, open-sourced, and it being developed to this day.

otouto uses a robust plugin system, similar to that of yagop's [telegram-bot](github.com/yagop/telegram-bot). The aim of the project is to contain any desirable feature inside one universal bot.

* * *

##Plugins
Here is a list of most otouto plugins.

| Plugin | Command | Function | Alias |
|--------|---------|----------|-------|
| help.lua | /help | Returns a list of commands. | /h |
| about.lua | /about | Returns the about text as configured in config.lua. |
| apod.lua | /apod [query] | Gets Astronomy Picture of the Day for current day, or for a specific date (YYYY-MM-DD). | |
| ping.lua | /ping | The simplest plugin ever! |
| echo.lua | /echo <text> | Repeats a string of text. |
| gSearch.lua | /google <query> | Returns Google web results. | /g, /gnsfw |
| gImages.lua | /images <query> | Returns a Google image result. | /i, /insfw |
| gMaps.lua | /location <query> | Returns location data from Google Maps. | /loc |
| youtube.lua | /youtube <query> | Returns the top video result from YouTube. | /yt |
| wikipedia.lua | /wikipedia <query> | Returns the summary of a Wikipedia article. | /wiki |
| lastfm.lua | /np [username] | Returns the song you are currently listening to. |
| lastfm.lua | /fmset [username] | Sets your username for /np. /fmset - will delete it. |
| hackernews.lua | /hackernews | Returns the latest posts from Hacker News. | /hn |
| imdb.lua | /imdb <query> | Returns film information from IMDb. |
| hearthstone.lua | /hearthstone <query> | Returns data for Hearthstone cards matching the query. | /hs |
| calc.lua | /calc <expression> | Returns solutions to math expressions and conversions between common units. |
| bible.lua | /bible <reference> | Returns a Bible verse. | /b |
| urbandictionary.lua | /urbandictionary <query> | Returns the top definition from Urban Dictionary. | /ud, /urban |
| time.lua | /time <query> | Returns the time, date, and a timezone for a location. |
| weather.lua | /weather <query> | Returns current weather conditions for a given location. |
| nick.lua | /nick <nickname> | Set your nickname. /nick - will delete it. |
| whoami.lua | /whoami | Returns user and chat info for you or the replied-to user. | /who |
| eightball.lua | /8ball | Returns an answer from a magic 8-ball. |
| dice.lua | /roll <nDr> | Returns RNG dice rolls. Uses D&D notation. |
| reddit.lua | /reddit [r/subreddit \| query] | Returns the top results from a given subreddit, query, or r/all. | /r |
| xkcd.lua | /xkcd [query] | Returns an xkcd strip and its alt text. |
| slap.lua | /slap <target> | Gives someone a slap (or worse). |
| commit.lua | /commit | Returns a commit message from whatthecommit.com. |
| fortune.lua | /fortune | Returns a UNIX fortune. |
| pun.lua | /pun | Returns a pun. |
| pokedex.lua | /pokedex <query> | Returns a Pokedex entry. | /dex |
| currency.lua | /cash [amount] <currency> to <currency> | Converts one currency to another. |
| cats.lua | /cat | Returns a cat picture. |
| reactions.lua | /reactions | Returns a list of reaction emoticons which can be used through the bot. |
| apod.lua | /apod [date] | Returns the NASA Astronomy Picture of the Day. |
| control.lua | /reload | Reloads all plugins, libraries, and configuration files. |
| control.lua | /halt | Stops the bot. If the bot was run with launch.sh, this will restart it. |
| blacklist.lua | /blacklist <ID> | Blacklists or unblacklists a user, via reply or ID, from using your bot. |
| shell.lua | /shell <command> | Runs a shell command and returns the output. Use with caution. |
| luarun.lua | /lua <command> | Runs a string a Lua code and returns the output, if applicable. Use with caution. otouto does not use a sandbox. |

* * *

## administration.lua
The administration plugin enables self-hosted, single-realm group administration, supporting both normal groups and supergroups. This works by sending TCP commands to an instance of tg running on the owner's account.

To get started, run `./tg-install.sh`. Note that this script is written for Ubuntu/Debian. If you're running Arch (the only acceptable alternative), you'll have to do it yourself. If that is the case, note that otouto uses the "test" branch of tg, and the AUR package `telegram-cli-git` will not be sufficient, as it does not have support for supergroups yet.

Once the installation is finished, enable `administration.lua` in your config file. You may have reason to change the default TCP port (4567); if that is the case, remember to change it in `tg-launch.sh` as well. Run `./tg-launch.sh` in a separate screen/tmux window. You'll have to enter your phone number and go through the login process the first time. The script is set to restart tg after two seconds, so you'll need to Ctrl+C after exiting.

While tg is running, you may start/reload otouto with administration.lua enabled, and have access to a wide variety of administrative commands and automata. The administration "database" is stored in `administration.json`. To start using otouto to administrate a group (note that you must be the owner (or an administrator)), send `/gadd` to that group. For a list of commands, use `/ahelp`. Below I'll describe various functions now available to you.

| Command | Function | Privilege | Internal? |
|---------|----------|-----------|-----------|
| /groups | Returns a list of administrated groups (except those flagged "unlisted". | 1 | N |
| /ahelp | Returns a list of administrative commands and their required privileges. | 1 | Y |
| /ops | Returns a list of moderators, governors, and administrators. | 1 | Y |
| /rules | Returns the rules of a group. | 1 | Y |
| /motd | Returns a group's "Message of the Day". | 1 | Y |
| /link | Returns the link for a group. | 1 | Y |
| /leave | Removes the user from the group. | 1 | Y |
| /kick | Removes the target from the group. | 2 | Y |
| /ban | Bans the target from the group. | 2 | Y |
| /unban | Unbans the target from the group. | 2 | Y |
| /setrules | Sets the rules for a group. | 3 | Y |
| /setmotd | Sets a group's "Message of the Day". | 3 | Y |
| /setlink | Sets a group's link. | 3 | Y |
| /flag | Returns a list of available flags and their settings, or toggles a flag. | 3 | Y |
| /mod | Promotes a user to a moderator. | 3 | Y |
| /demod | Demotes a moderator to a user. | 3 | Y |
| /gov | Promotes a user to a governor. | 4 | Y |
| /degov | Demotes a governor to a user. | 4 | Y |
| /hammer | Bans a user from all groups. | 4 | N |
| /unhammer | Removes a global ban. | 4 | N |
| /admin | Promotes a user to an administrator. | 5 | N |
| /deadmin | Demotes an administrator to a user. | 5 | N |
| /gadd | Adds a group to the administrative system. | 5 | N |
| /grem | Removes a group from the administrative system | 5 | Y |
| /broadcast | Broadcasts a message to all administrated groups. | 5 | N |

Internal commands can only be run within an administrated group.

###Description of Privileges

| # | Title | Description | Scope |
|------|-------|-------------|-------|
| 0 | Banned | Cannot enter the group(s). | Either |
| 1 | User | Default rank. | Local |
| 2 | Moderator | Can kick/ban/unban users from a group. | Local |
| 3 | Governor | Can set rules/motd/link. Can promote/demote moderators. Can modify flags. | Local |
| 4 | Administrator | Can globally ban/unban users. Can promote/demote governors. | Global |
| 5 | Owner | Can add/remove groups. Can broadcast. Can promote/demote administrators. | Global |

Obviously, each greater rank inherits the privileges of the lower, positive ranks.

###Flags

| # | Name | Description |
|---|------|-------------|
| 1 | unlisted | Removes a group from the /groups listing. |
| 2 | antisquig | Automatically removes users for posting Arabic script or RTL characters. |
| 3 | antisquig Strict | Automatically removes users whose names contain Arabic script or RTL characters. |
| 4 | antibot | Prevents bots from being added by non-moderators. |

* * *

##Liberbot Plugins
Some plugins are only useful when the bot is used in a Liberbot group, like floodcontrol.lua and moderation.lua.

**floodcontrol.lua** makes the bot compliant with Liberbot's floodcontrol function. When the bot has posted too many messages to a single group in a given period of time, Liberbot will send it a message telling it to cease posting in that group. Here is an example floodcontrol command:

`/floodcontrol {"groupid":987654321,"duration":600}`

The bot will accept these commands from both Liberbot and the configured administrator.

**moderation.lua** allows the owner to use the bot to moderate a Liberbot realm, or set of groups. This works by adding the bot to the realm's admin group and making it an administrator.

You must configure the plugin in the "moderation" section of config.lua, in the following way:

```
moderation = {
    admins = {
        ['123456789'] = 'Adam',
        ['246813579'] = 'Eve'
    },
    admin_group = -987654321,
    realm_name = 'My Realm'
}
```

Where Adam and Eve are realm administrators, and their IDs are set as their keys in the form of strings. admin_group is the group ID of the admin group, as a negative number. realm_name is the name of your Libebot realm.

Once this is set up, put your bot in the admin group and run /add and /modhelp to get started.

Where the key is the preconfigured response (where #NAME will be replaced with the user's name or nickname) and the strings in the table are the expected greetings (followed by the bot's name and possible punctuation).

* * *

##Setup
You **must** have Lua (5.2+), LuaSocket, and LuaSec installed. For uploading photos and other files, you must have curl installed. The fortune.lua plugin requires that fortune is installed.

For weather.lua, lastfm.lua, and bible.lua to work, you must have API keys for [OpenWeatherMap](http://openweathermap.org), [last.fm](http://last.fm), and [Biblia.com](http://biblia.com), respectively. cats.lua uses an API key (via [The Cat API](http://thecatapi.com)) to get more results, though it is not required. apod.lua uses an API key (via [NASA API](https://api.nasa.gov/)) to have more queries per minute, though it is not required.

**Before you do anything, open config.lua in a text editor and make the following changes:**

> • Set bot_api_key to the authentication token you received from the Botfather.
>
> • Set admin as your Telegram ID.

You may also want to set your time_offset (a positive or negative number, in seconds, representing your computer's difference from UTC), your lang (lowercase, two-letter code representing your language), and modify your about_text. Some plugins will not be enabled by default, as they are for specific uses. If you want to use them, add them to the plugins table.

To start the bot, run `./launch.sh`. To stop the bot, press Ctrl+c twice.

You may also start the bot with `lua bot.lua`, but then it will not restart automatically.

* * *

##Development
Everybody is free to contribute to otouto. Here I will explain various things that are important to know about the plugin system.

A plugin can have five components, and three of them are optional: action, triggers, doc, command, and cron.

| Component | Description | Optional? |
|-----------|-------------|-----------|
| action | The main function of a plugin. It accepts the `msg` table. | No. |
| triggers | A table of strings which, when one is matched in a message's text, will cause `action` to be run. | No. |
| doc | The help text to be returned when a plugin is run with improper syntax or arguments. | Yes |
| command | The command with its syntax, without the slash. This is used to generate the help text. | Yes |
| cron | A function to be run every five seconds. | Yes |

The on_msg_receive function adds a few variables to the "msg" table: msg.from.id_str, msg.to.id_str, msg.text_lower. These are self-explanatory and can make your code a lot neater.

Return values from the action function are optional, but when they are used, they determine the fate of the message. When false/nil is returned, on_msg_receive stops and the script moves on to waiting for the next message. When true is returned, on_msg_receive continues going through the plugins for a match. When a table is returned, that table becomes the "msg" table, and on_msg_receive continues.

When a plugin action or cron function fails, the script will catch the error and print it, and, if applicable, the text which triggered the plugin, and continue.

* * *

Interactions with the Telegram bot API are straightforward. Every function is named the same as the API method it utilizes. The order of expected arguments is laid out in bindings.lua.

There are three functions which are not API methods: sendRequest, curlRequest, and sendReply. The first two are used by the other functions. sendReply is used directly. It expects the "msg" table as its first argument, and a string of text as its second. It will send a reply without image preview to the initial message.

* * *

Several functions and methods used by multiple plugins and possibly the main script are kept in utilities.lua. Refer to that file for documentation.

otouto uses dkjson, a pure-Lua JSON parser. This is provided with the code and does not need to be downloaded or installed separately.

* * *

##Contributors
The creator and maintainer of otouto is [topkecleon](http://github.com/topkecleon). He can be contacted via [Telegram](http://telegram.me/topkecleon), [Twitter](http://twitter.com/topkecleon), or [email](mailto:topkecleon@outlook.com).

Other developers who have contributed to otouto are [Juan Potato](http://github.com/JuanPotato), [Tiago Danin](http://github.com/TiagoDanin), [Ender](http://github.com/luksireiku), [Iman Daneshi](http://github.com/Imandaneshi), and [HeitorPB](https://github.com/heitorPB).

