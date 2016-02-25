dilbert = dilbert or {}

local command = 'dilbert [date]'
local doc = [[```
/dilbert [YYYY-MM-DD]
Returns the latest Dilbert strip or that of the provided date.
Dates before the first strip will return the first strip. Dates after the last trip will return the last strip.
Source: dilbert.com
```]]

local triggers = {
	'^/dilbert[@'..bot.username..']*'
}

local action = function(msg)

	sendChatAction(msg.chat.id, 'upload_photo')

	local input = msg.text:input()
	if not input then input = os.date('%F') end
	if not input:match('^%d%d%d%d%-%d%d%-%d%d$') then input = os.date('%F') end

	local url = 'http://dilbert.com/strip/' .. URL.escape(input)
	local str, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	if not dilbert[input] then
		local strip_url = str:match('<meta property="og:image" content="(.-)"/>')
		dilbert[input] = download_file(strip_url, '/tmp/' .. input .. '.gif')
	end

	local strip_title = str:match('<meta property="article:publish_date" content="(.-)"/>')

	sendPhoto(msg.chat.id, dilbert[input], strip_title)

end

return {
	command = command,
	doc = doc,
	triggers = triggers,
	action = action
}
