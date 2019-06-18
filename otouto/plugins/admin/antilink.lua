--[[
    antilink.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local anise = require('anise')

local bindings = require('extern.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'antilink'
    self.flag_desc = 'Posting links to other groups is not allowed.'
    flags_plugin.flags[self.flag] = self.flag_desc

    self.help_word = 'antilink'
    self.doc = "\z
antilink checks links and usernames posted by non-moderators. If a message \z
references a group or channel outside the realm, an automoderation strike is \z
issued (see /help automoderation) and the user's global antilink counter is \z
incremented. When his counter reaches 3, he is globally banned and \z
immediately removed from all groups where antilink was triggered. \
antilink can be enabled with /flag antilink (see /help flags)."

    -- Build the antilink patterns. Additional future domains can be added to
    -- this list to keep it up to date.
    self.patterns = {}
    for _, domain in pairs{
        'telegram.me',
        'telegram.dog',
        'tlgrm.me',
        't.me'
    } do
        local s = ''
        -- We build the pattern character by character from the domains.
        -- May become an issue when emoji TLDs become mainstream. ;)
        for char in domain:gmatch('.') do
            if char:match('%l') then
                s = s .. '[' .. char:upper() .. char .. ']'
            -- all characters which must be escaped
            elseif char:match('[%%%.%^%$%+%-%*%?]') then
                s = s .. '%' .. char
            else
                s = s .. char
            end
        end
        table.insert(self.patterns, s)
    end
    self.triggers = anise.clone(self.patterns)
    table.insert(self.triggers, '@[%w_]+')

    -- Infractions are stored, and users are globally banned after three within
    -- one day of each other.
    if not bot.database.userdata.antilink then
        bot.database.userdata.antilink = {}
    end

    self.administration = true
end

function P:action(bot, msg, group, user)
    local admin = group.data.admin
    if not admin.flags[self.flag] then return 'continue' end
    if user:rank(bot, msg.chat.id) > 1 then return 'continue' end
    if msg.forward_from and (
        (msg.forward_from.id == bot.info.id) or
        (msg.forward_from.id == bot.config.log_chat) or
        (msg.forward_from.id == bot.config.administration.log_chat)
    ) then
        return 'continue'
    end
    if self:check(bot, msg) then
        local store = user.data.antilink
        if not store then
            store = {
                count = 0,
                groups = {},
            }
            user.data.antilink = store
        end
        store.count = store.count + 1
        store.groups[tostring(msg.chat.id)] = true

        bot:do_later(self.name, os.time() + 86400, msg.from.id)

        if store.count == 3 then
            user.data.hammered = true
            bindings.deleteMessage{ chat_id = msg.chat.id,
                message_id = msg.message_id }
            autils.log(bot, {
                chat_id = not admin.flags.private and msg.chat.id,
                target = msg.from.id,
                action = 'Globally banned',
                source = self.flag,
                reason = self.flag_desc
            })
            for chat_id_str, _ in pairs(store.groups) do
                bindings.kickChatMember{
                    chat_id = chat_id_str,
                    user_id = msg.from.id
                }
            end
            user.data.antilink = nil
        else
            autils.strike(bot, msg, self.flag)
        end
    else
        return 'continue'
    end
end

function P:later(bot, user_id)
    local store = bot.database.userdata.antilink[tostring(user_id)]
    if store then
        if store.count > 1 then
            store.count = store.count - 1
        else
            bot.database.userdata.antilink[tostring(user_id)] = nil
        end
    end
end

P.edit_action = P.action

 -- Links can come from the message text or from entities, and can be joinchat
 -- links (t.me/joinchat/abcdefgh), username links (t.me/abcdefgh), or usernames
 -- (@abcdefgh).
function P:check(bot, msg)
    for _, pattern in pairs(self.patterns) do

        -- Iterate through links in the message, and determine if they refer to
        -- external groups.
        for link in msg.text:gmatch(pattern..'%g*') do
            if self:parse_and_detect(bot, link, pattern) then
                return true
            end
        end

        -- Iterate through the messages's entities, if any, and determine if
        -- they're links to external groups.
        if msg.entities then
            for _, entity in ipairs(msg.entities) do
                if entity.url and self:parse_and_detect(bot, entity.url, pattern) then
                    return true
                end
            end
        end
    end

    -- Iterate through all usernames in the message text, and determine if they
    -- are external group links.
    for username in msg.text:gmatch('@([%w_]+)') do
        if
            not (msg.forward_from_chat and username == msg.forward_from_chat.username)
            and self:is_username_external(bot, username)
        then
            return true
        end
    end
end

 -- This function takes a link or username (parsed from a message or found in an
 -- entity) and returns true if that link or username refers to a supergroup
 -- outside of the realm.
function P:parse_and_detect(bot, link, pattern)
    local code = link:match(pattern .. -- /joinchat/ABC-def_123
        '/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/([%w_%-]+)')
    local username = link:match(pattern .. '/([%w_]+)')
    if (code and self:is_code_external(bot, code)) or
        (username and self:is_username_external(bot, username))
    then
        return true
    end
end

 -- This function determines whether or not a given joinchat "code" refers to
 -- a group outside the realm (true/false)
function P:is_code_external(bot, code)
    -- Prepare the code to be used as a pattern by escaping any hyphens.
    -- Also, add an anchor.
    local pattern = '/' .. code:gsub('%-', '%%-') .. '$'
    -- Iterate through groups and return false if the joinchat code belongs to
    -- any one of them.
    for _, group in pairs(bot.database.groupdata.admin) do
        if group.link:match(pattern) then
            return false
        end
    end
    return true
end

 -- This function determines whether or not a username refers to a supergroup
 -- outside the realm (true/false).
function P:is_username_external(bot, username)
    local suc, res = bindings.getChat{chat_id = '@' .. username}
    -- If the username is an external supergroup or channel, return true.
    if suc and (res.result.type=='supergroup' or res.result.type=='channel') and
        not bot.database.groupdata.admin[tostring(res.result.id)] then
            return true
    end
    return false
end

return P
