 --[[
    hearthstone.lua
    Returns Hearthstone card data.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local JSON = require('dkjson')
local utilities = require('otouto.utilities')
local HTTPS = require('ssl.https')

local hearthstone = {}

function hearthstone:init()
    hearthstone.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('hearthstone', true):t('hs').table
    hearthstone.command = 'hearthstone <query>'

    if not self.database.hearthstone or os.time() > self.database.hearthstone.expiration then

        print('Downloading Hearthstone database...')

        local jstr, res = HTTPS.request('https://api.hearthstonejson.com/v1/latest/enUS/cards.json')
        if not jstr or res ~= 200 then
            print('Error connecting to hearthstonejson.com.')
            print('hearthstone.lua will not be enabled.')
            hearthstone.command = nil
            hearthstone.triggers = nil
            return
        end
        self.database.hearthstone = JSON.decode(jstr)
        self.database.hearthstone.expiration = os.time() + 600000

        print('Download complete! It will be stored for a week.')

    end

    hearthstone.doc = self.config.cmd_pat .. [[hearthstone <query>
Returns Hearthstone card info.
Alias: ]] .. self.config.cmd_pat .. 'hs'
end

local function format_card(card)

    local ctype = card.type
    if card.race then
        ctype = card.race
    end
    if card.rarity then
        ctype = card.rarity .. ' ' .. ctype
    end
    if card.playerClass then
        ctype = ctype .. ' (' .. card.playerClass .. ')'
    elseif card.faction then
        ctype = ctype .. ' (' .. card.faction .. ')'
    end

    local stats
    if card.cost then
        stats = card.cost .. 'c'
        if card.attack then
            stats = stats .. ' | ' .. card.attack .. 'a'
        end
        if card.health then
            stats = stats .. ' | ' .. card.health .. 'h'
        end
        if card.durability then
            stats = stats .. ' | ' .. card.durability .. 'd'
        end
    elseif card.health then
        stats = card.health .. 'h'
    end

    -- unused?
    local info
    if card.text then
        info = card.text:gsub('</?.->',''):gsub('%$','')
        if card.flavor then
            info = info .. '\n_' .. card.flavor .. '_'
        end
    elseif card.flavor then
        info = card.flavor
    else
        info = nil
    end

    local s = '*' .. card.name .. '*\n' .. ctype
    if stats then
        s = s .. '\n' .. stats
    end
    if info then
        s = s .. '\n' .. info
    end

    return s

end

function hearthstone:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, hearthstone.doc, 'html')
        return
    end

    local output = ''
    for _,v in pairs(self.database.hearthstone) do
        if type(v) == 'table' and string.lower(v.name):match(input) then
            output = output .. format_card(v) .. '\n\n'
        end
    end

    output = utilities.trim(output)
    if output:len() == 0 then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    utilities.send_message(msg.chat.id, output, true, msg.message_id, true)

end

return hearthstone
