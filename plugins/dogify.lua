local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[dogify <lines/separatedby/slashes>
	Produces a doge image from dogr.io. Newlines are indicated by a forward slash. Words do not need to be spaced, but spacing is supported. Will post a previewed link rather than an image.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'doge ',
	'^' .. config.COMMAND_START .. 'dogify '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local input = string.gsub(input, ' ', '')

	url = 'http://dogr.io/' .. input .. '.png'

	send_message(msg.chat.id, url, false, msg.message_id)

end

return PLUGIN
