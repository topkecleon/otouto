# otouto

The plugin-wielding, multi-purpose Telegram bot.

Public bot runs on [@mokubot](http://telegram.me/mokubot).

To start, send "/start" or say "Hello, otouto."


##Plugins

<table>
  <thead>
    <tr>
      <td>help.lua</td>
      <td>/help [command]</td>
      <td>List commands</td>
    </tr>
    <tr>
      <td>about.lua</td>
      <td>/about</td>
      <td>Information about the bot</td>
    </tr>
    <tr>
      <td>gSearch.lua</td>
      <td>/google &lt;query&gt;</td>
      <td>Google Search</td>
    </tr>
    <tr>
      <td>gImages.lua</td>
      <td>/images &lt;query&gt;</td>
      <td>Google Images search</td>
    </tr>
    <tr>
      <td>reddit.lua</td>
      <td>/reddit [r/subreddit | query]</td>
      <td>Posts from reddit</td>
    </tr>
    <tr>
      <td>giphy.lua</td>
      <td>/giphy [query]</td>
      <td>Giphy search or random</td>
    </tr>
    <tr>
      <td>xkcd.lua</td>
      <td>/xkcd [search]</td>
      <td>xkcd strips and alt text</td>
    </tr>
    <tr>
      <td>gMaps.lua</td>
      <td>/loc &lt;location&gt;</td>
      <td>Google Maps search</td>
    </tr>
    <tr>
      <td>imdb.lua</td>
      <td>/imdb &lt;movie | TV series&gt;</td>
      <td>IMDb movie/television info</td>
    </tr>
    <tr>
      <td>urbandictionary.lua</td>
      <td>/ud &lt;term&gt;</td>
      <td>Urban Dictionary search</td>
    </tr>
    <tr>
      <td>hackernews.lua</td>
      <td>/hackernews</td>
      <td>Top stories from Hackernews</td>
    </tr>
    <tr>
      <td>time.lua</td>
      <td>/time &lt;location&gt;</td>
      <td>Get the time for a place</td>
    </tr>
    <tr>
      <td>weather.lua</td>
      <td>/weather &lt;location&gt;</td>
      <td>Get the weather for a place</td>
    </tr>
    <tr>
      <td>calc.lua</td>
      <td>/calc &lt;expression&gt;</td>
      <td>Solve math expression and convert units</td>
    </tr>
    <tr>
      <td>dice.lua</td>
      <td>/roll [arg]</td>
      <td>Roll a die. Accepts D&amp;D notation</td>
    </tr>
    <tr>
      <td>remind.lua</td>
      <td>/remind &lt;delay&gt; &lt;message&gt;</td>
      <td>Set a reminder for yourself or a group</td>
    </tr>
    <tr>
      <td>8ball.lua</td>
      <td>/8ball</td>
      <td>Magic 8-ball</td>
    </tr>
    <tr>
      <td>bandersnatch.lua</td>
      <td>/bandersnatch</td>
      <td>Benedict Cumberbatch name generator</td>
    </tr>
    <tr>
      <td>bible.lua</td>
      <td>/bible &lt;verse&gt;</td>
      <td>King James Version</td>
    </tr>
    <tr>
      <td>btc.lua</td>
      <td>/btc &lt;currency&gt; [amount]</td>
      <td>Bitcoin prices and conversion</td>
    </tr>
    <tr>
      <td>commit.lua</td>
      <td>/commit</td>
      <td>http://whatthecommit.com</td>
    </tr>
    <tr>
      <td>dogify.lua</td>
      <td>/dogify &lt;lines/separatedby/slashes&gt;</td>
      <td>Create a doge image</td>
    </tr>
    <tr>
      <td>echo.lua</td>
      <td>/echo &lt;text&gt;</td>
      <td>Repeat a string</td>
    </tr>
    <tr>
      <td>fortune.lua</td>
      <td>/fortune</td>
      <td>Random fortunes</td>
    </tr>
    <tr>
      <td>hex.lua</td>
      <td>/hex &lt;number&gt;</td>
      <td>Convert to and from hexadecimal</td>
    </tr>
    <tr>
      <td>pokedex.lua</td>
      <td>/dex &lt;pokemon&gt;</td>
      <td>Pokedex!</td>
    </tr>
    <tr>
      <td>pun.lua</td>
      <td>/pun</td>
      <td>Puns</td>
    </tr>
    <tr>
      <td>slap.lua</td>
      <td>/slap [victim]</td>
      <td>Slap someone!</td>
    </tr>
    <tr>
      <td>whoami.lua</td>
      <td>/who</td>
      <td>Get user and group IDs</td>
    </tr>
  </tbody>
</table>


##Setup

Requires Lua, lua-socket and lua-sec. [dkjson](http://github.com/LuaDist/dkjson/) is provided. Written for Lua 5.2 but will probably run on 5.3.

You must have a Telegram bot and auth token from the [BotFather](http://telegram.me/botfather) to run this bot. telegram-cli is not required.

###Configuration

To begin, copy config.lua.default to config.lua and add the relevant information.

Most config.lua entries are self-explanatory.

Add your bot API key, and other API keys if desirable.
The plugins which require API keys that are not provided are disabled by default.
The provided Giphy key is the public test key, and is subject to rate limitaton.

The "fortune.lua" plugin requires the fortune program to be installed on the host computer.

"time_offset" is the time difference, in seconds, between your system clock. It is sometimes necessary for accurate output of the time plugin.

"admins" table includes the ID numbers, as integers, of any privileged users. These will have access to the admin plugin and any addition privileged commands.

"people" table is for the personality plugin:
`["55994550"] = "topkecleon"`

ID number must be a string. The second string is the nickname to be given to the identified user when a personality greeting is triggered.

To run:

`lua bot.lua`


##Support

Do not private message me for support.

For support for otouto as well as general Lua and bot assistance, please join the [CIS Bot Development](http://telegram.me/joinchat/05fe39f500f8f1b2d1548147a68acd2a) group. After you read the rules and the pastebin, I will assist you there.

PS - Since there seems to be some confusion on the matter, otouto is *not* a port of yagop's telegram-bot. I am friends with yagop, and he is part of the Bot Development group, but our codebases are and always have been entirely separate. otouto was a CLI bot like telegram-bot before the new API, but they were entirely separate, non-intermingled projects.
