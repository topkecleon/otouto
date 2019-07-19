--[[
    urban_dictionary.lua
    Returns Urban Dictionary definitions. Now featuring paging and links!

    Copyright 2019 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local json = require('dkjson')
local url = require('socket.url')
local https = require('ssl.https')

local bindings = require('extern.bindings')
local utilities = require('otouto.utilities')
local anise = require('extern.anise')

local P = {}

local three_hours = 60 * 60 * 3

function P:init(bot)
    self.command = 'urbandictionary [query]'
    self.doc = string.format(
        'Search the Urban Dictionary.\nAliases: %sud, %surban\n\zBy default, \z
        results include an inline keyboard for paging and related terms. Use \z
        %sud1 for only paging buttons. Use %sud0 for no keyboard.',
        bot.config.cmd_pat,
        bot.config.cmd_pat,
        bot.config.cmd_pat,
        bot.config.cmd_pat
    )
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('ud%d?', true)
        :t('urbandictionary', true)
        :t('urban', true).table

    self.kb_level_pattern = '^' .. bot.config.cmd_pat .. 'ud(%d)'

    -- Cache to store definition lists.
    -- Should provide a noticeable speed benefit for paging.
    self.cache = {}

    -- Schedule a job to clear expired cached lists.
    bot:do_later(self.name, os.time() + three_hours)

    self.url = 'http://api.urbandictionary.com/v0/define?term='
end

function P:action(bot, msg)
    local query = utilities.input_from_msg(msg)
    if query then
        local list = self:fetch(url.escape(query))
        if list ~= false then
            if #list > 0 then
                local kb_level = tonumber(msg.text:lower():match(self.kb_level_pattern) or 2)
                local message = self:create_message(list, 1, kb_level)
                message.chat_id = msg.chat.id
                message.reply_to_message_id = msg.message_id
                bindings.sendMessage(message)
            else
                utilities.send_reply(msg, bot.config.errors.results)
            end
        else
            utilities.send_reply(msg, bot.config.errors.connection)
        end
    else
        utilities.send_plugin_help(msg.chat.id, msg.message_id, bot.config.cmd_pat, self)
    end
end

function P:callback_action(_, query)
    local escaped_term = utilities.get_word(query.data, 2)
    local def_num = tonumber(utilities.get_word(query.data, 3))
    local kb_level = tonumber(utilities.get_word(query.data, 4))

    local new_list = P:fetch(escaped_term)
    local new_message = self:create_message(new_list, def_num, kb_level)
    new_message.chat_id = query.message.chat.id
    new_message.message_id = query.message.message_id
    new_message.parse_mode = 'html'
    new_message.disable_web_page_preview = true

    bindings.editMessageText(new_message)
end

 -- Clear cached results which have expired.
function P:later(bot)
    for term, tab in pairs(self.cache) do
        if tab.expires < os.time() then
            self.cache[term] = nil
        end
    end
    -- Schedule another check in three hours.
    bot:do_later(self.name, os.time() + three_hours)
end

 -- Fetch a list of definitions from the Urban Dictionary API or the cache.
function P:fetch(escaped_term)
    escaped_term = escaped_term:lower()
    -- If the term is cached, use that.
    if self.cache[escaped_term] then
        -- Reset the expiration date.
        self.cache[escaped_term].expires = os.time() + three_hours
        return self.cache[escaped_term].list
    else
        -- Otherwise, check the API.
        local jstr, response = https.request(self.url .. escaped_term)
        if response == 200 then
            local data = json.decode(jstr)

            -- Cache the results.
            self.cache[escaped_term] = {
                expires = os.time() + three_hours,
                list = data.list
            }

            return data.list
        else
            return false
        end
    end
end

 -- i is the index of the entry which should be display.
 -- kb_level: 0 is no keyboard. 1 is paging keyboard. 2 is full keyboard.
 -- Paging keyboard provides arrows to navigate through several entries for
 -- one term. Full keyboard provides arrows as well as keys for related terms
 -- which are linked in the definition.
function P:create_message(list, i, kb_level)
    local entry = list[i]
    local message = {
        parse_mode = 'html',
        disable_web_page_preview = true,
        text = self.format_entry(list, i)
    }

    if kb_level > 0 then
        -- Initialize the keyboard.
        local keyboard = utilities.keyboard('inline_keyboard')

        -- Paging arrows if there is more than one entry for the term.
        if #list > 1 then
            local prev_entry_num = list[i - 1] and i - 1 or #list
            local next_entry_num = list[i + 1] and i + 1 or 1
            local escaped_term = url.escape(entry.word)

            keyboard:row()
            keyboard:button('◀️', 'callback_data', string.format(
                '%s %s %s %s',
                self.name,
                escaped_term,
                prev_entry_num,
                kb_level
            ))
            keyboard:button('▶️', 'callback_data', string.format(
                '%s %s %s %s',
                self.name,
                escaped_term,
                next_entry_num,
                kb_level
            ))
        end

        if kb_level > 1 then
            -- Set for all terms appearing in the definition or example, which will be on buttons on the keyboard.
            local linked_terms = anise.set()
            -- Iterate over bracketed terms in the definition.
            for term in entry.definition:gmatch('%[(.-)%]') do
                -- Don't add a term if it's the same as the initial term.
                if term:lower() ~= entry.word:lower() then
                    linked_terms:add(term:lower())
                end
            end
            -- Iterate over bracketed terms in the example.
            for term in entry.example:gmatch('%[(.-)%]') do
                if term:lower() ~= entry.word:lower() then
                    linked_terms:add(term:lower())
                end
            end

            -- Populate with linked terms.
            local j = 0
            for term in pairs(linked_terms) do
                -- When there are three buttons in a row, a new row is started.
                if j % 3 == 0 then
                    keyboard:row()
                end
                keyboard:button(term, 'callback_data', string.format(
                    '%s %s %s %s',
                    self.name,
                    url.escape(term),
                    1,
                    kb_level
                ))
                j = j + 1
            end
        end

        -- Prep the functions
        message.reply_markup = keyboard:serialize()
    end

    return message
end

function P.format_entry(list, i)
    local entry = list[i]
    local definition = entry.definition:gsub('%[(.-)%]', '%1')
    local text = string.format(
        '<b>%s</b> (<a href="%s">%s of %s</a>)\n<i>%s</i>\n\n%s',
        entry.word,
        entry.permalink,
        i,
        #list,
        entry.written_on:sub(1, 10),
        utilities.html_escape(definition)
    )
    if entry.example then
        local example = entry.example:gsub('%[(.-)%]', '%1')
        text = text .. '\n\n<i>' .. utilities.html_escape(example) .. '</i>'
    end
    return text
end

return P
