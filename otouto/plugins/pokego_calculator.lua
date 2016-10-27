--[[
    pokego_calculator.lua
    A calculator for optimizing the use of Lucky Eggs in Pokemon Go.

    Copyright 2015-2016 Juan Potato

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.
]]--

local utilities = require('otouto.utilities')

local pgc = {}

function pgc:init()
    pgc.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('gocalc', true).table
    pgc.doc = self.config.cmd_pat .. [[gocalc <required candy> <number of Pokémon> <number of candy>
Calculates the number of Pokémon that must be transferred before evolving, how many evolutions the user is able to perform, and how many Pokémon and candy will be left over.
All arguments must be positive numbers. Batch jobs may be performed by separating valid sets of arguments by lines.
Example (forty pidgeys and three hundred pidgey candies):
]] .. self.config.cmd_pat .. 'gocalc 12 40 300'
    pgc.command = 'gocalc <required candy> <#pokemon> <#candy>'
end

local function pidgey_calc(candies_to_evolve, mons, candies)
    local transferred = 0;
    local evolved = 0;

    while true do
        if math.floor(candies / candies_to_evolve) == 0 or mons == 0 then
            break
        else
            mons = mons - 1
            candies = candies - candies_to_evolve + 1
            evolved = evolved + 1
            if mons == 0 then
                break
            end
        end
    end

    while true do
        if (candies + mons) < (candies_to_evolve + 1) or mons == 0 then
            break
        end
        while candies < candies_to_evolve do
            transferred = transferred + 1
            mons = mons - 1
            candies = candies + 1
        end
        mons = mons - 1
        candies = candies - candies_to_evolve + 1
        evolved = evolved + 1
    end

    return {
        transfer = transferred,
        evolve = evolved,
        leftover_mons = mons,
        leftover_candy = candies
    }
end

local function single_job(input)
    local req_candy, mons, candies = input:match('^(%d+) (%d+) (%d+)$')
    req_candy = tonumber(req_candy)
    mons = tonumber(mons)
    candies = tonumber(candies)
    if not (req_candy and mons and candies) then
        return { err = 'Invalid input: Three numbers expected.' }
    elseif req_candy > 400 then
        return { err = 'Invalid required candy: Maximum is 400.' }
    elseif mons > 1000 then
        return { err = 'Invalid number of Pokémon: Maximum is 1000.' }
    elseif candies > 10000 then
        return { err = 'Invalid number of candies: Maximum is 10000.' }
    else
        return pidgey_calc(req_candy, mons, candies)
    end
end

function pgc:action(msg)
    local input = utilities.input(msg.text)
    if not input then
        utilities.send_reply(msg, pgc.doc, 'html')
        return
    end
    input = input .. '\n'
    local output = ''
    local total_evolutions = 0
    for line in input:gmatch('(.-)\n') do
        local info = single_job(line)
        output = output .. '`' .. line .. '`\n'
        if info.err then
            output = output .. info.err .. '\n\n'
        else
            total_evolutions = total_evolutions + info.evolve
            local s = '*Transfer:* %s. \n*Evolve:* %s (%s XP, %s minutes). \n*Leftover:* %s mons, %s candy.\n\n'
            s = s:format(info.transfer, info.evolve, info.evolve..'k', info.evolve*0.5, info.leftover_mons, info.leftover_candy)
            output = output .. s
        end
    end
    local s = '*Total evolutions:* %s. \n*Recommendation:* %s'
    local recommendation
    local egg_count = math.floor(total_evolutions/60)
    if egg_count < 1 then
        recommendation = 'Wait until you have atleast sixty Pokémon to evolve before using a lucky egg.'
    else
        recommendation = string.format(
            'Use %s lucky egg%s for %s evolutions.',
            egg_count,
            egg_count == 1 and '' or 's',
            egg_count * 60
        )
    end
    s = s:format(total_evolutions, recommendation)
    output = output .. s
    utilities.send_reply(msg, output, true)
end

return pgc
