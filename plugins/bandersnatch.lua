local PLUGIN = {}

PLUGIN.doc = [[
	/bandersnatch
	This is a Benedict Cumberbatch name generator.
]]

PLUGIN.triggers = {
	'^/bandersnatch',
	'^/bc$'
}

PLUGIN.fullnames = { "Wimbledon Tennismatch", "Rinkydink Curdlesnoot", "Butawhiteboy Cantbekhan", "Benadryl Claritin", "Bombadil Rivendell", "Wanda's Crotchfruit", "Biblical Concubine", "Syphilis Cankersore", "Buckminster Fullerene", "Bourgeoisie Capitalist" }

PLUGIN.firstnames = { "Bumblebee", "Bandersnatch", "Broccoli", "Rinkydink", "Bombadil", "Boilerdang", "Bandicoot", "Fragglerock", "Muffintop", "Congleton", "Blubberdick", "Buffalo", "Benadryl", "Butterfree", "Burberry", "Whippersnatch", "Buttermilk", "Beezlebub", "Budapest", "Boilerdang", "Blubberwhale", "Bumberstump", "Bulbasaur", "Cogglesnatch", "Liverswort", "Bodybuild", "Johnnycash", "Bendydick", "Burgerking", "Bonaparte", "Bunsenburner", "Billiardball", "Bukkake", "Baseballmitt", "Blubberbutt", "Baseballbat", "Rumblesack", "Barister", "Danglerack", "Rinkydink", "Bombadil", "Honkytonk", "Billyray", "Bumbleshack", "Snorkeldink", "Anglerfish", "Beetlejuice", "Bedlington", "Bandicoot", "Boobytrap", "Blenderdick", "Bentobox", "Anallube", "Pallettown", "Wimbledon", "Buttercup", "Blasphemy", "Snorkeldink", "Brandenburg", "Barbituate", "Snozzlebert", "Tiddleywomp", "Bouillabaisse", "Wellington", "Benetton", "Bendandsnap", "Timothy", "Brewery", "Bentobox", "Brandybuck", "Benjamin", "Buckminster", "Bourgeoisie", "Bakery", "Oscarbait", "Buckyball", "Bourgeoisie", "Burlington", "Buckingham", "Barnoldswick" }

PLUGIN.lastnames = { "Coddleswort", "Crumplesack", "Curdlesnoot", "Calldispatch", "Humperdinck", "Rivendell", "Cuttlefish", "Lingerie", "Vegemite", "Ampersand", "Cumberbund", "Candycrush", "Clombyclomp", "Cragglethatch", "Nottinghill", "Cabbagepatch", "Camouflage","Creamsicle", "Curdlemilk", "Upperclass", "Frumblesnatch", "Crumplehorn", "Talisman", "Candlestick", "Chesterfield", "Bumbersplat", "Scratchnsniff", "Snugglesnatch", "Charizard", "Carrotstick", "Cumbercooch", "Crackerjack", "Crucifix", "Cuckatoo", "Cockletit", "Collywog", "Capncrunch", "Covergirl", "Cumbersnatch", "Countryside","Coggleswort", "Splishnsplash", "Copperwire", "Animorph", "Curdledmilk", "Cheddarcheese", "Cottagecheese", "Crumplehorn", "Snickersbar", "Banglesnatch", "Stinkyrash", "Cameltoe", "Chickenbroth", "Concubine", "Candygram", "Moldyspore", "Chuckecheese", "Cankersore", "Crimpysnitch", "Wafflesmack", "Chowderpants", "Toodlesnoot", "Clavichord", "Cuckooclock", "Oxfordshire", "Cumbersome", "Chickenstrips", "Battleship", "Commonwealth", "Cunningsnatch", "Custardbath", "Kryptonite", "Curdlesnoot", "Cummerbund", "Coochyrash", "Crackerdong", "Crackerdong", "Curdledong", "Crackersprout", "Crumplebutt", "Colonist", "Coochierash", "Thundersnatch" }

function PLUGIN.action(msg)

	math.randomseed(os.time())

	local message = ''
	if math.random(10) == 10 then
		message = PLUGIN.fullnames[math.random(#PLUGIN.fullnames)]
	else
		message = PLUGIN.firstnames[math.random(#PLUGIN.firstnames)] .. ' ' .. PLUGIN.lastnames[math.random(#PLUGIN.lastnames)]
	end

	send_msg(msg, message)
end

return PLUGIN
