 -- Credit to Juan (tg:JuanPotato; gh:JuanPotato) for this plugin.
 -- Or rather, the seven lines that actually mean anything.

local bing = {}

local URL = require('socket.url')
local JSON = require('dkjson')
local mime = require('mime')
local https = require('ssl.https')
local ltn12 = require('ltn12')
local utilities = require('otouto.utilities')

bing.command = 'bing <query>'
bing.doc = [[```
/bing <query>
Returns the top web search results from Bing.
Aliases: /g, /google
```]]

bing.search_url = 'https://api.datamarket.azure.com/Data.ashx/Bing/Search/Web?Query=\'%s\'&$format=json'

function bing:init(config)
	if not config.bing_api_key then
		print('Missing config value: bing_api_key.')
		print('bing.lua will not be enabled.')
		return
	end
	bing.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('bing', true):t('g', true):t('google', true).table
end

function bing:action(msg, config)
	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text ~= '' then
			input = msg.reply_to_message.text
		else
			utilities.send_reply(self, msg, bing.doc, true)
			return
		end
	end
	local url = bing.search_url:format(URL.escape(input))
	local resbody = {}
	local _,b,_ = https.request{
	    url = url,
	    headers = { ["Authorization"] = "Basic " .. mime.b64(":" .. config.bing_api_key) },
	    sink = ltn12.sink.table(resbody),
	}
	if b ~= 200 then
		utilities.send_reply(self, msg, config.errors.results)
		return
	end
	local dat = JSON.decode(table.concat(resbody))
	local limit = 4
	if msg.chat.type == 'private' then
		limit = 8
	end
	if limit > #dat.d.results then
		limit = #dat.d.results
	end
	local reslist = {}
	for i = 1, limit do
		local result = dat.d.results[i]
		local s = '• [' .. result.Title:gsub('%]', '\\]') .. '](' .. result.Url:gsub('%)', '\\)') .. ')'
		table.insert(reslist, s)
	end
	local output = '*Search results for* _' .. utilities.md_escape(input) .. '_ *:*\n' .. table.concat(reslist, '\n')
	utilities.send_message(self, msg.chat.id, output, true, nil, true)
end

return bing
