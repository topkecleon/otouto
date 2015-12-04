#otouto
The plugin-wielding, multipurpose Telegram bot.

The public bot runs on [@mokubot](https://telegram.me/mokubot).

otouto is licensed under the GNU General Public License. A copy of the license has been included in [LICENSE](https://github.com/topkecleon/otouto/blob/master/LICENSE).

##What is it?
otouto is an independently-developed Telegram API bot written in Lua. otouto was created in February 2015, open-sourced in June, and is being augmented to this day.

Bot commands and functions use a comprehensive plugin system, similar to that of (yagop's telegram-bot)[github.com/yagop/telegram-bot]. The aim of the project is to host every desirable feature in one bot.

##Plugins
Below are listed many (but not all) of otouto's plugins. This list will be updated as more plugins are added.

###**echo.lua**

>**Command:** /echo &lt;text&gt;

>**Function:** Repeats a string of text.

>**Notes:** Replaces letters with corresponding characters from the Cyrillic alphabet.

###**gSearch.lua**

>**Command:** /google [query]

>**Function:** Returns four or eight Google results, depending on whether it is run in a group chat or a private message.

>**Aliases:** /g, /gnsfw, /googlensfw

>**Notes:** If "nsfw" is appended to the command, Safe Search will not be used.

###**gImages.lua**

>**Command:** /images [query]

>**Function:** Returns a random top result from Google Image.

>**Aliases:** /i, /gimages, /gnsfw

>**Notes:** If "nsfw" is appended to the command, Safe Search and image preview will not be used.

###**gMaps.lua**

>**Command:** /location [query]

>**Function:** Returns location data from Google Maps.

>**Aliases:** /loc

###**translate.lua**

>**Command:** /translate [text]

>**Function:** Translates the replied-to message or the given string to the configured language.

###**youtube.lua**

>**Command:** /youtube [query]

>**Function:** Returns the top video result from YouTube.

>**Aliases:** /yt

###**wikipedia.lua**

>**Command:** /wikipedia [query]

>**Function:** Returns the top paragraph of and the link to a Wikipedia article.

>**Aliases:** /wiki

###**lastfm.lua**

>**Command:** /lastfm

>**Function**: Returns help for the last.fm actions.

>**Actions**:

>>**/np** [username]

>>Returns the current- or last-played song for the given username. If no username is given, it will use your configured last.fm username or your Telegram username.


>>**/fmset** &lt;username&gt;

>>Sets your last.fm username. Use /fmset - to delete it.

###**hackernews.lua**

>**Command:** /hackernews

>**Function:** Returns the top four or eight headlines on Hacker News, depending on whether it is run in a group chat or private message.

>**Aliases:** /hn

###**imdb.lua**

>**Command:** /imdb &lt;query&gt;

>**Function:** Returns movie information from IMDb.

###**calc.lua**

>**Command:** /calc &lt;expression&gt;

>**Function:** Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.

###**bible.lua**

>**Command:** /bible &lt;reference&gt;

>**Function:** Returns a Bible verse. Results provided by biblia.com

>**Aliases:** /b

###**urbandictionary.lua**

>**Command:** /urbandictionary &lt;query&gt;

>**Function:** Returns the top definition from Urban Dictionary.

>**Aliases:** /ud, /urban

###**time.lua**

>**Command:** /time &lt;query&gt;

>**Function:** Returns the time, date, and timezone for a given location.

###**weather.lua**

>**Command:** /weather &lt;query&gt;

>**Function:** Returns the current weather conditions for a given location.

###**nick.lua**

>**Command:** /nick &lt;nickname&gt;

>**Function:** Set your nickname. Use "/nick -" to delete it.

###**whoami.lua**

>**Command:** /whoami

>**Function:** Returns user and chat info for your or the replied-to message.

###**8ball.lua**

>**Command:** /8ball

>**Function:** Returns an answer from a magic 8-ball.

###**dice.lua**

>**Command:** /roll &lt;nDr&gt;

>**Function:** Returns RNG dice rolls. Uses D&D notation.

>**Examples:**

>>/roll 4D20

>>/roll 6

###**reddit.lua**

>**Command:** /reddit [r/subreddit | query]

>**Function:** Returns the top four or eight results, depending on whether it is run in a group chat or private message, from a given subreddit, query, or r/all.

>**Aliases:** /r

>**Notes:** You may also get results for a subreddit by entering "/r/subreddit".

>**Examples:**

>> /reddit zelda

>> /reddit r/gaming

>>/r/talesfromtechsupport

###**xkcd.lua**

>**Command:** /xkcd [query]

>**Function:** Returns an xkcd strip and it's alt text. If not query is given, it will use a random strip.

###**slap.lua**

>**Command:** /slap &lt;target&gt;

>**Function:** Give someone a good slap (or worse).

###**commit.lua**

>**Command:** /commit

>**Function:** Returns a commit message from whatthecommit.com.

###**fortune.lua**

>**Command:** /fortune

>**Function:** Returns a UNIX fortune.

###**pun.lua**

>**Command:** /pun

>**Function:** Returns a pun.

###**pokedex.lua**

>**Command:** /pokedex &lt;query&gt;

>**Function:** Returns a Pokedex entry.

>**Aliases:** /dex

###**currency.lua**

>**Command:** /cash [amount] &lt;from&gt; to &lt;from&gt;

>**Function:** Converts an amount of one currency to another.

>**Examples:**

>>/cash 5 USD to EUR

>>/cash BTC to GBP

###**cats.lua**

>**Command:** /cat

>**Function:** Returns a cat pic.

###**hearthstone.lua**

>**Command:** /hearthstone &lt;query&gt;

>**Function:** Returns Hearthstone card info.

>**Aliases:** /hs

###**admin.lua**

>**Command:** /admin [command]

>**Function:** Runs an admin command or returns a list of them.

>**Notes:** Only usable by the configured admin.

###**blacklist.lua**

>**Command:** /blacklist [id]

>**Function:** Blacklists or unblacklists the specified ID or replied-to user.

>**Notes:** Only usable by the configured admin.

##Liberbot Plugins
Some plugins are only useful when the bot is used in a Liberbot group: moderation.lua, antisquig.lua, floodcontrol.lua.

floodcontrol.lua makes the bot compliant to Liberbot's bot floodcontrol. It should prevent your bot from being globally banned from Liberbot groups.

moderation.lua allows realm administrators to assign moderators for a group. This only works if the bot is made a realm administrator.

You must configure this plugin in the "moderation" section of config.lua, in the following way:

```
moderation = {
	admins = {
		['123456789'] = 'Adam',
		['1337420'] = 'Eve'
	},
	admin_group = -8675309,
	realm_name = 'My Realm'
}
```

Where Adam and Eve are realm administrators, and their IDs are set as the keys in the form of strings. admin_group is the ID, a negative number, of the realm administration group. realm_name is the name as a string.

Once this is set up, put the bot in the admin group and run /add and /modlist to get started.

antisquig.lua is an extension to moderation.lua. It will automatically kick a user who posts Arabic script.

##Other Plugins
There are other plugins not listed above: help.lua, about.lua, chatter.lua, greetings.lua.

help.lua is self-explanatory. When the plugin loads, it compiles a list of commands, and will return them.

about.lua returns the content of the about_text string in config.lua.

chatter.lua will let the user interact with a chatterbot, if he replies to a message sent by the bot.

greetings.lua is where things get tricky. It allows the bot to respond to several greetings with a preconfigured response. This is configured in the "greetings" section of config.lua:

```
greetings = {
	['Hello, #NAME.'] = {
		'hello',
		'hey',
		'hi'
	},
	['Goodbye, #NAME.'] = {
		'goodbye',
		'bye',
	}
}
```

Where the key is the preconfigured response (where #NAME will be replaced with the user's name or nickname) and the strings in the table are the expected greetings (followed by the bot's name and possible punctuation).

##Setup
You **must** have Lua, lua-socket and lua-sec installed. For uploading photos and other files, you must have curl installed. The fortune.lua plugin requires that fortune is installed.

For weather.lua, lastfm.lua, and bible.lua to work, you must have API keys for openweathermap.org, last.fm, and biblia.com, respectively. cats.lua uses an API key to get more results, though it is not required.

>**Before you do anything, edit config.lua and make the following changes:**

>* Edit bot_api_key with your authentication token from Botfather.
>* Set admin as your Telegram ID as a number.

You may also want to set your time_offset (a positive or negative number, in seconds, representing your computer's difference from UTC), your lang (lowercase, two-letter code representing your language), and modify your about_text. Some plugins will not be enabled by default, as they are for specific uses. If you want to use them, add them to the plugins table.

To start the bot, run

`./launch.sh`

To stop the bot, press Ctrl+C twice.

You may also start the bot manually with

`lua bot.lua`

though that will not cause it to automatically restart.

##Support
Do not contact me through private messages for support.

For otouto, bot, and other Lua support in general, join the Bot Development group. Send "/join 16314802" to [@Liberbot](https://telegram.me/liberbot). If this does not work the first time, you may need to send it up to seven more times, thanks to Telegram's automatic spam-prevention mechanism.

##Development
Everyone is free to contribute to otouto. If you would like to write a plugin, here I will lay out various things that are important to know about the plugin system.

Every plugin has four components, and half of them are optional: action, triggers, doc, cron.

triggers is a table of strings using Lua patterns which, when matched by a message's text, will "trigger" the action function. This is not optional.

action is the main function of a plugin. It accepts the "msg" table, which is all the components of the message, as an argument. This is not optional.

doc is the documentation. The first line is the expected command and arguments. Arguments in square braces are considered optional and those in angled braces are considered required. This is optional.

cron is a function run every five seconds. This is optional.

The on_msg_receive function adds a few variables to the "msg" table: msg.from.id_str, msg.to.id_str, msg.text_lower. These are self-explanatory and make code a lot neater.

Return values from the action function are optional, but when they are used, they determine the fate of the message. When false/nil is returned, on_msg_receive stops and the script moves on to waiting for the next message. When true is returned, on_msg_receive continues going through the plugins for a match. When a table is returned, that table becomes the "msg" table, and on_msg_receive continues.

When a plugin action or cron function fails, the script will catch the error and print it, and, if applicable, the text which triggered the plugin, and continue.

----

Interactions with the Telegram bot API are straightforward. Every function is named the same as the API method it utilizes. The order of expected arguments is laid out in bindings.lua.

There are three functions which are not API methods: sendRequest, curlRequest, and sendReply. The first two are used by the other functions. sendReply is used directly. It expects the "msg" table as its first argument, and a string of text as its second. It will send a reply without image preview to the initial message.

----

Several functions and methods used by multiple plugins and possibly the main script are kept in utilities.lua. Refer to that file for documentation.

----

otouto uses dkjson, a pure-Lua JSON parser. This is provided with the code and does not need to be downloaded or installed separately.
