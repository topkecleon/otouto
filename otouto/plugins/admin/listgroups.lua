--[[
    listgroups.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')
local plists

local P = {}

function P:init(bot)
    plists = bot.named_plugins['core.paged_lists']
    assert(plists, self.name .. ' requires core.paged_lists.')
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('groups?', true):t('listgroups', true).table
    self.command = 'listgroups [query]'
    self.doc = "/groups [query]\
Returns a list of all public, administrated groups, or the results of a query."
end

function P:action(bot, msg)
    local input = utilities.input_from_msg(msg)
    input = input and input:lower()

    -- Output will be a list of results, a list of all groups, or an explanation
    -- that there are no (listed) groups.
    local titles_and_links = {}
    for id_str, chat in pairs(bot.database.groupdata.admin) do
        if not chat.flags.private then
            table.insert(titles_and_links,
                bot.database.groupdata.info[id_str].title .. chat.link)
        end
    end

    local listed_groups = {}
    local results = {}
    table.sort(titles_and_links)
    for _, s in ipairs(titles_and_links) do
        local a, b = s:match('^(.+)(https://.-)$')
        local fmtd = string.format('<a href="%s">%s</a>', b, utilities.html_escape(a))
        table.insert(listed_groups, fmtd)
        if input and a:lower():find(input, 1, true) then
            table.insert(results, fmtd)
        end
    end

    local output
    if input then
        if #results == 0 then
            output = bot.config.errors.results
        else
            plists:list(bot, msg, results, 'Group Results', msg.chat.id)
        end
    elseif #listed_groups == 0 then
        output = 'There are no listed groups.'
    else
        local success, result = plists:list(bot, msg, listed_groups, 'Groups')
        if success then
            if result.result.chat.id ~= msg.chat.id then
                output = 'I have sent you the requested info privately.'
            else
                bindings.deleteMessage{
                    chat_id = msg.chat.id,
                    message_id = msg.message_id
                }
            end
        else
            output = 'Please <a href="https://t.me/' .. bot.info.username
                .. '?start=groups">message me privately</a> first.'
        end
    end
    if output then utilities.send_reply(msg, output, 'html') end
end

return P
