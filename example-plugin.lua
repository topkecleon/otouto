local doc = [[
	/example <required> [optional]
	Info about the plugin goes here.
]]

local triggers = {
	'^/example',
	'^/e '
}

local action = function(msg) do

	-- do stuff

end

local cron = function() do

	-- do stuff

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	cron = cron,
	typing = true
}

--[[

Here's an example plugin.

"doc" is a string. It contains info on the plugin's usage.
The first line should be only the command and its expected arguments. Arguments should be encased in <> if they are required, and [] if they are optional.
The entire thing is sent as a message when "/help example" is used.

"triggers" is a table of triggers. A trigger is a string that should pattern-match the desired input.

"action" is the main function. It's what the plugin does. It takes a single argument, msg, which is a table of the contents of a message.

"cron" is another function. It is run every five seconds without regard to triggers or messages.

"typing" is a boolean. Set it to true if you want the bot to send a typing notification when the plugin is triggered.

]]--
