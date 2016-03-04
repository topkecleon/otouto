# otouto
The plugin-wielding, multipurpose Telegram bot.

[Public Bot](http://telegram.me/mokubot) | [Official Channel](http://telegram.me/otouto) | [Development Group](http://telegram.me/BotDevelopment) | [Owner's Manual](http://otou.to/rtfm)

otouto is an independently-developed Telegram API bot written in Lua. Originally conceived as a CLI script in February of 2015, otouto has since been open-sourced and migrated to the API, and is being developed to this day.

## Setup {#Setup}
You _must_ have Lua (5.2+), lua-socket, lua-sec, and lua-cjson installed. To upload files, you must have curl installed. To use fortune.lua, you must have fortune installed.

**Before doing anything**, open config.lua and set `bot_api_key` to the authentication token you received from the Botfather.

You may want to set: `admin`, your Telegram ID; `time_offset`, a positive or negative number, denoting the difference, in seconds, of your system clock to UTC; and `lang`, a lowercase, two-letter code representing your language. Some plugins are not enabled by default. If you wish to enable them, add them to the `plugins` table (before help.lua).

To start the bot, run `./launch.sh`. To stop the bot, send "/halt" from your admin account, and then Ctrl+C out of the loop. If you terminate the bot manually, you risk data loss. If you do not wish the bot to restart automatically, run it with `lua bot.lua`.

Note that certain plugins, such as translate.lua and greetings.lua, will require privacy mode to be disabled. Additionally, some plugins may require or make use of various API keys:

 - weather.lua: [OpenWeatherMap](http://openweathermap.org) API key
 - lastfm.lua: [last.fm](http://last.fm) API key
 - bible.lua: [Biblia](http://biblia.com) API key
 - cats.lua: [The Cat API](http://thecatapi.com) API key (optional)
 - gImages.lua: [Google](http://console.developers.google.com) API and CSE keys
 - youtube.lua: [Google](http://console.developers.google.com) API key
 - apod.lua: [NASA](http://api.nasa.gov) API key
 - translate.lua: [Yandex](https://tech.yandex.com/keys/get/?service=trnsl) API key
 - chatter.lua: [SimSimi](http://developer.simsimi.com/signUp) API key

* * *

## Plugins {#Plugins}
otouto uses a robust plugin system, similar to that of yagop's [Telegram-Bot](http://github.com/yagop/telegram-bot). The aim of the otouto project is to contain any desirable bot feature within one universal bot framework.

Most plugins are intended for public use, but a few are for other purposes, like those used alongside [Liberbot](#Liberbot-related_plugins), or for [use by the bot's owner](#Control_plugins). See [Development](#Development) for a breakdown of the components of a plugin, or [here](#List_of_plugins) for a list of plugins.

A plugin can have five components, and two of them are required:

| Component | Description | Required? |
|:----------|:------------|:----------|
| action | The main function. It accepts the `msg` table as an argument. | Y |
| triggers | A table of commands to be used for the plugin. Use Lua patterns. | Y |
| cron | An optional function to be called approximately every minute. | N |
| command | The basic command and syntax. This is listed in the help text. | N |
| doc | Usage and other info for the plugin. This is returned with "/help command" | N |

The `on_msg_receive()` function adds a few variables to the `msg` table for your convenience. These are self-explanatory: `msg.from.id_str`, `msg.to.id_str`, `msg.chat.id_str`, `msg.text_lower`, `msg.from.name`.

Return values from `action()` are optional, but they do effect the flow. If it returns a table, that table will become `msg`, and `on_msg_receive` will continue with that. If it returns `true`, it will continue with the current `msg`.

When an action or cron function fails, the exception is caught and passed to the `handle_exception()` utilty (in utilities.lua) and is either printed to the console or send to the chat/channel defined in `log_chat` in config.lua.

Interactions with the bot API are straightforward. Every binding function shares the name of the API method (eg `sendMessage()`). An additional function, `sendReply()`, accepts the `msg` table and a string as an argument, and sends the string as a reply to that message.

Several functions used in multiple plugins are defined in utilities.lua. Refer to that file for usage and documentation.

* * *

## Control plugins {#Control_plugins}
Some plugins are designed to be used by the bot's owner. Here are some examples, how they're used, and what they do.

| Plugin | Command | Function |
|:-------|:--------|:---------|
| control.lua | /reload | Reloads all plugins and configuration. |
| control.lua | /halt | Saves the database and shuts down the bot properly. |
| blacklist.lua | /blacklist | Allows the admin to list people the bot will ignore. |
| shell.lua | /run | Executes shell commands on the host operating system. |
| luarun.lua | /lua | Executes Lua commands in the bot's environement. |

* * *

## administration.lua {#administration.lua}
The administration plugin enables self-hosted, single-realm group administration, supporting both normal groups and supergroups. This works by sending TCP commands to an instance of tg running on the owner's account.

To get started, run `./tg-install.sh`. Note that this script is written for Ubuntu/Debian. If you're running Arch (the only acceptable alternative), you'll have to do it yourself. If that is the case, note that otouto uses the "test" branch of tg, and the AUR package `telegram-cli-git` will not be sufficient, as it does not have support for supergroups yet.

Once the installation is finished, enable `administration.lua` in your config file. You may have reason to change the default TCP port (4567); if that is the case, remember to change it in `tg-launch.sh` as well. Run `./tg-launch.sh` in a separate screen/tmux window. You'll have to enter your phone number and go through the login process the first time. The script is set to restart tg after two seconds, so you'll need to Ctrl+C after exiting.

While tg is running, you may start/reload otouto with administration.lua enabled, and have access to a wide variety of administrative commands and automata. The administration "database" is stored in `administration.json`. To start using otouto to administrate a group (note that you must be the owner (or an administrator)), send `/gadd` to that group. For a list of commands, use `/ahelp`. Below I'll describe various functions now available to you.

| Command | Function | Privilege | Internal? |
|:--------|:---------|:----------|:----------|
| /groups | Returns a list of administrated groups (except those flagged "unlisted". | 1 | N |
| /ahelp | Returns a list of administrative commands and their required privileges. | 1 | Y |
| /ops | Returns a list of moderators, governors, and administrators. | 1 | Y |
| /desc | Returns the link, rules, MOTD, and enabled flags of a group. | 1 | Y |
| /rules | Returns the rules of a group. | 1 | Y |
| /motd | Returns a group's "Message of the Day". | 1 | Y |
| /link | Returns the link for a group. | 1 | Y |
| /leave | Removes the user from the group. | 1 | Y |
| /kick | Removes the target from the group. | 2 | Y |
| /ban | Bans the target from the group. | 2 | Y |
| /unban | Unbans the target from the group. | 2 | Y |
| /changerule | Changes an individual group rule. | 3 | Y |
| /setrules | Sets the rules for a group. | 3 | Y |
| /setmotd | Sets a group's "Message of the Day". | 3 | Y |
| /setlink | Sets a group's link. | 3 | Y |
| /flag | Returns a list of available flags and their settings, or toggles a flag. | 3 | Y |
| /mod | Promotes a user to a moderator. | 3 | Y |
| /demod | Demotes a moderator to a user. | 3 | Y |
| /gov | Promotes a user to a governor. | 4 | Y |
| /degov | Demotes a governor to a user. | 4 | Y |
| /hammer | Bans a user globally, and blacklists him. | 4 | N |
| /unhammer | Removes a user's global ban, and unblacklists him. | 4 | N |
| /admin | Promotes a user to an administrator. | 5 | N |
| /deadmin | Demotes an administrator to a user. | 5 | N |
| /gadd | Adds a group to the administrative system. | 5 | N |
| /grem | Removes a group from the administrative system | 5 | Y |
| /broadcast | Broadcasts a message to all administrated groups. | 5 | N |

Internal commands can only be run within an administrated group.

### Description of Privileges

| # | Title | Description | Scope |
|:-:|:------|:------------|:------|
| 0 | Banned | Cannot enter the group(s). | Either |
| 1 | User | Default rank. | Local |
| 2 | Moderator | Can kick/ban/unban users from a group. | Local |
| 3 | Governor | Can set rules/motd/link. Can promote/demote moderators. Can modify flags. | Local |
| 4 | Administrator | Can globally ban/unban users. Can promote/demote governors. | Global |
| 5 | Owner | Can add/remove groups. Can broadcast. Can promote/demote administrators. | Global |

Obviously, each greater rank inherits the privileges of the lower, positive ranks.

### Flags

| # | Name | Description |
|:-:|:-----|:------------|
| 1 | unlisted | Removes a group from the /groups listing. |
| 2 | antisquig | Automatically removes users for posting Arabic script or RTL characters. |
| 3 | antisquig Strict | Automatically removes users whose names contain Arabic script or RTL characters. |
| 4 | antibot | Prevents bots from being added by non-moderators. |

* * *

# Liberbot-related plugins {#Liberbot-related_plugins}
**Note:** This section may be out of date. The Liberbot-related plugins have not changed in very long time.
Some plugins are only useful when the bot is used in a Liberbot group, like floodcontrol.lua and moderation.lua.

**floodcontrol.lua** makes the bot compliant with Liberbot's floodcontrol function. When the bot has posted too many messages to a single group in a given period of time, Liberbot will send it a message telling it to cease posting in that group. Here is an example floodcontrol command:
`/floodcontrol {"groupid":987654321,"duration":600}`
The bot will accept these commands from both Liberbot and the configured administrator.

**moderation.lua** allows the owner to use the bot to moderate a Liberbot realm, or set of groups. This works by adding the bot to the realm's admin group and making it an administrator.
You must configure the plugin in the "moderation" section of config.lua, in the following way:
```lua
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

Once this is set up, put your bot in the admin group and run `/modadd` and `/modhelp` to get started.

* * *

## List of plugins {#List_of_plugins}

| Plugin | Command | Function | Aliases |
|:-------|:--------|:---------|:--------|
| help.lua | /help | Returns a list of commands. | /h |
| about.lua | /about | Returns the about text as configured in config.lua. |
| ping.lua | /ping | The simplest plugin ever! |
| echo.lua | /echo <text> | Repeats a string of text. |
| gSearch.lua | /google <query> | Returns Google web results. | /g, /gnsfw |
| gImages.lua | /images <query> | Returns a Google image result. | /i, /insfw |
| gMaps.lua | /location <query> | Returns location data from Google Maps. | /loc |
| youtube.lua | /youtube <query> | Returns the top video result from YouTube. | /yt |
| wikipedia.lua | /wikipedia <query> | Returns the summary of a Wikipedia article. | /wiki |
| lastfm.lua | /np [username] | Returns the song you are currently listening to. |
| lastfm.lua | /fmset [username] | Sets your username for /np. /fmset -- will delete it. |
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
| reddit.lua | /reddit [r/subreddit ¦ query] | Returns the top results from a given subreddit, query, or r/all. | /r |
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
| dilbert.lua | /dilbert [date] | Returns a Dilbert strip. |
| patterns.lua | /s/<from>/<to>/ | Fixed that for you. :^) |

* * *

## Style {#Style}
Bot output from every plugin should follow a consistent style. This style is easily observed interacting with the bot.
Titles should be either **bold** (along with their colons) or a [link](http://otou.to) (with plaintext colons) to the content's source. Names should be _italic_. Numbered lists should use bold numbers followed by a bold period followed by a space. Unnumbered lists should use the • bullet point followed by a space. Descriptions and information should be in plaintext, although "flavor" text should be italic. Technical information should be `monospace`. Links should be named.

## Contributors {#Contributors}
Everybody is free to contribute to otouto. If you are interested, you are invited to fork the [repo](http://github.com/topkecleon/otouto) and start making pull requests.. If you have an idea and you are not sure how to implement it, open an issue or bring it up in the Bot Development group.

The creator and maintainer of otouto is [topkecleon](http://github.com/topkecleon). He can be contacted via [Telegram](http://telegram.me/topkecleon), [Twitter](http://twitter.com/topkecleon), or [email](mailto:drew@otou.to).

There are a a few ways to contribute if you are not a programmer. For one, your feedback is always appreciated. Drop me a line on Telegram or on Twitter. Secondly, we are always looking for new ideas for plugins. Most new plugins start with community input. Feel free to suggest them on Github or in the Bot Dev group. You can also donate Bitcoin to the following address:
`1BxegZJ73hPu218UrtiY8druC7LwLr82gS`

Contributions are appreciated in any form. Monetary contributions will go toward server costs. Both programmers and donators will be eternally honored (at their discretion) on this page.

| Contributors |
|:-----------|
| [Juan Potato](http://github.com/JuanPotato) |
| [Tiago Danin](http://github.com/TiagoDanin) |
| [bb010g](http://github.com/bb010g) |
| [Ender](http://github.com/luksireiku) |
| [Iman Daneshi](http://github.com/Imandaneshi) |
| [HeitorPB](http://github.com/heitorPB) |
| [Akronix](http://github.com/Akronix) |
| [Ville](http://github.com/cwxda) |
| [dogtopus](http://github.com/dogtopus) |

| Donators |
|:---------|
| [n8](http://telegram.me/n8_c00) |
| [Alex](http://telegram.me/sandu) |
| [Brayden Banks](http://telegram.me/bb010g) |
