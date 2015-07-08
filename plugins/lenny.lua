local PLUGIN = {}

PLUGIN.triggers = {
	'/lenny'
}

function PLUGIN.action(msg)
	send_msg(msg, '( ͡° ͜ʖ ͡°)')
end

return PLUGIN
