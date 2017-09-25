--[[
    regex.lua
    Sed-like substitution using PCRE regular expressions. Ignores commands with
    no reply-to message.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local regex = {}

local utilities = require('otouto.utilities')

local re = require('re')
local rex = require('rex_pcre')

function regex:init()
    regex.command = 's/<pattern>/<substitution>'
    regex.help_word = 'regex'
    regex.doc = [[s/<pattern>/<substitution>[/<modifiers>]
Replace all matches for the given pattern.
Uses PCRE regexes.

Modifiers are [<flags>][#<matches>][%probability]:
* Flags are i, m, s, x, U, and X, as per PCRE
* Matches is how many matches to replace
  (all matches are replaced by default)
* Probability is the percentage that a match will
  be replaced (100 by default)]]
    regex.triggers = { self.config.cmd_pat .. '?s/.-/.-$' }
end

local invoke_pattern = re.compile[[
invocation <- 's/' {~ pcre ~} '/' {~ repl ~} ('/' modifiers)? !.
pcre <- ( [^\/] / f_slash / '\' )*
repl <- ( [^\/%$] / percent / f_slash / capture / '\' / '$' )*

modifiers <- { flags? } {~ n_matches? ~} {~ probability? ~}

flags <- ('i' / 'm' / 's' / 'x' / 'U' / 'X')+
n_matches <- ('#' {[0-9]+}) -> '%1'
probability <- ('%' {[0-9]+}) -> '%1'

f_slash <- ('\' '/') -> '/'
percent <- '%' -> '%%%%'
capture <- ('$' {[0-9]+}) -> '%%%1'
]]

function regex:action(msg)
    -- Return if there is no message to change.
    if not msg.reply_to_message then return true end

    local input = msg.reply_to_message.text
    if msg.reply_to_message.from.id == self.info.id then
        input = input:match('^Did you mean:\n"(.+)"$') or input
    end

    -- self.config.cmd_pat has to be one byte for this to work
    local text = msg.text:match('^' .. self.config.cmd_pat .. '?(.*)$')
    if not text then return end

    local patt, repl, flags, n_matches, probability = invoke_pattern:match(text)
    if not patt then return end

    if n_matches then n_matches = tonumber(n_matches) end
    if probability then probability = tonumber(probability) end
    if probability then
        if not n_matches then
            n_matches = function ()
                return math.random() * 100 < probability
            end
        else
            local matches_left = n_matches
            n_matches = function ()
                local tmp
                if matches_left > 0 then
                    tmp = nil
                else
                    tmp = 0
                end
                matches_left = matches_left - 1
                return math.random() * 100 < probability, tmp
            end
        end
    end

    local success, result, n_matched = pcall(function ()
        return rex.gsub(input, patt, repl, n_matches, flags)
    end)

    if success == false then -- Error occurred; probably a bad pattern.
        utilities.send_reply(msg, 'Malformed pattern!')
        return
    elseif n_matched == 0 then -- No matches occurred.
        return
    else -- Success.
        local output = utilities.trim(result:sub(1, 4000))
        output = '<b>Did you mean:</b>\n"' .. utilities.html_escape(output) .. '"'
        utilities.send_reply(msg.reply_to_message, output, 'html')
    end
end

return regex
