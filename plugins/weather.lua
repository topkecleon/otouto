local PLUGIN = {}

PLUGIN.doc = [[
	/weather <location>
	Returns the current temperature and weather conditions for a specified location.
	Non-city locations are accepted; "/weather Buckingham Palace" will return the weather for Westminster.
	Results and weather data are powered by Yahoo.
]]

PLUGIN.triggers = {
	'^/weather'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'https://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20in%20%28select%20woeid%20from%20geo.places%281%29%20where%20text%3D%22' .. URL.escape(input) .. '%22%29&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local jdat = JSON.decode(jstr)
	if not jdat.query.results then
		return send_msg(msg, config.locale.errors.results)
	end
	local data = jdat.query.results.channel.item.condition

	local fahrenheit = data.temp
	local celsius = string.format('%.0f', (fahrenheit - 32) * 5/9)
	local message = celsius .. '°C | ' .. fahrenheit .. '°F, ' .. data.text .. '.'

	send_msg(msg, message)

end

return PLUGIN
