

The plugin-wielding, multi-purpose Telegram bot.

Based on otouto by [@topkecleon](http://telegram.me/topkecleon)

To start, send "/start" or say "Hello, jack."




# feathers/plugins list

**1-Help**

List commands

`/help` 

***

**2-About**

Information about the bot

`/about`

***

**3-Google Search**

Perform a Google search for you

`/google <query>`

![/google](http://s6.uplod.ir/i/00665/lmjw79okxtbi.png)


***

**4-Google Images search**

Perform a Google Images search for you

`/images <query>`

![/images](http://s6.uplod.ir/i/00665/urpc7s6j1p25.png)


***


**5-Posts from reddit**

Posts from reddit

`/reddit [r/subreddit | query]`


***


**6-Giphy**

Giphy search or random

`/giphy [query]`

![/giphy](http://s6.uplod.ir/i/00665/a6fffbua378j.png)


***


**7-Google Maps search**

Perform a Google Maps search for you

`/loc <location>`

![/loc](http://s6.uplod.ir/i/00665/65kxb5my02qx.png)


***

**8-IMDb**

IMDb movie/television info

`/imdb <movie | TV series>`

![/imdb](http://s6.uplod.ir/i/00665/tcfnwvfchsgk.png)


***

**9-Urban Dictionary**

Urban Dictionary search

`/ud <term>`


![/ud](http://s6.uplod.ir/i/00665/ekoe7jdo22bs.png)


***

**10-Time**

Get the time for a place

`/time <location>`

![/time](http://s6.uplod.ir/i/00665/owxw84ii2e5m.png)


***


**11-Weather**

Get the weather for a place

`/weather <location>`

![/weather](http://s6.uplod.ir/i/00665/0uflhecap8fn.png)

**12-Calculator**

***


Solve math expression and convert units

`/calc <expression>`

![/calc](http://s6.uplod.ir/i/00665/ug53xmbcdqu4.png)

***


**13-Remind**

Set a reminder for yourself or a group

`/remind <delay> <message>`

![/remind](http://s6.uplod.ir/i/00665/ggaqonabz9wj.png)

***


**14-8ball**

Magic 8-ball

`/8ball`


***

**15-Bitcoin**

Bitcoin prices and conversion

`/btc <currency> [amount]`

![/btc](http://s6.uplod.ir/i/00665/nyy9eim3rnvn.png)


***
**16-dogify**

Create a doge image

`/dogify <lines/separatedby/slashes>`

![/dogify](http://s6.uplod.ir/i/00665/se5v6jprtpqp.png)


***

**17-Echo**

Repeat a string

`/echo <text>`

![/echo](http://s6.uplod.ir/i/00665/s5kznagq86gv.png)


***

**18-Pun**

Puns 

`/pun`

**19-Slap**

***


Slap someone!

`/slap [victim]`

![/slap](http://s6.uplod.ir/i/00665/2glwd0lms7fd.png)

**20-whoami**

***


Get user and group IDs

`/who`

![/who](http://s6.uplod.ir/i/00665/ys5dmuzta3om.png)

**20-Translate**

***


 Reply to a message to translate it to the default language

`/translate [target lang]`

![/translate](http://s6.uplod.ir/i/00665/2nzk90nsc921.png)

## Setup

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
`["110626080"] = "imandaneshi"`

ID number must be a string. The second string is the nickname to be given to the identified user when a personality greeting is triggered.

To run:

`lua bot.lua`




## Contact 

Contact me if you had any suggestion or problem.

[@imandaneshi](http://telegram.me/imandaneshi)
[imandaneshi@yahoo.com](mailto:imandaneshi@yahoo.com)

