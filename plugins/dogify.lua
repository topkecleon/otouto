local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('dogify.COMMAND') .. ' <' .. I18N('dogify.ARG_STUFF') .. '>\n' .. I18N('dogify.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'doge ',
	'^' .. config.COMMAND_START .. I18N('dogify.COMMAND')
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
