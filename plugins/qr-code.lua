-- API Info: http://goqr.me/api/
-- ByTiagoDanin
local PLUGIN = {}

PLUGIN.doc = [[
	/qr <text>
	QR Code Generator.
]]

PLUGIN.triggers = {
	'^/qr'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end
	
  local url = 'http://api.qrserver.com/v1/create-qr-code/?size=500x500&data=' .. (URL.escape(input) or '')
	send_message(msg.chat.id, latcyr(url))

end

return PLUGIN
