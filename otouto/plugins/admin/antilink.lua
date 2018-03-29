local lume = require('lume')

local bindings = require('otouto.bindings')
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
    self.triggers = lume.clone(self.patterns)
    table.insert(self.triggers, '@[%w_]+')

    -- Infractions are stored, and users are globally banned after three within
    -- one day of each other.
    if not bot.database.administration.antilink then
        bot.database.administration.antilink = {}
    end
    self.store = bot.database.administration.antilink

    self.administration = true
end

function P:action(bot, msg, group, user)
    if not group.flags[self.flag] then return true end
    if user.rank > 1 then return true end
    if msg.forward_from and (
        (msg.forward_from.id == bot.info.id) or
        (msg.forward_from.id == bot.config.log_chat) or
        (msg.forward_from.id == bot.config.administration.log_chat)
    ) then
        return true
    end
    if self:check(bot, msg) then
        self.store[user.id_str] = self.store[user.id_str] or {
            count = 0,
            groups = {},
        }
        self.store[user.id_str].count = self.store[user.id_str].count +1
        self.store[user.id_str].groups[tostring(msg.chat.id)] = true
        self.store[user.id_str].latest = os.time()

        if self.store[user.id_str].count == 3 then
            bot.database.userdata.hammers[user.id_str] = true
            bindings.deleteMessage{ chat_id = msg.chat.id,
                message_id = msg.message_id }
            autils.log(bot, {
                chat_id = not group.flags.private and msg.chat.id,
                target = msg.from.id,
                action = 'Globally banned',
                source = self.flag,
                reason = self.flag_desc
            })
            for chat_id_str in pairs(self.store[user.id_str].groups) do
                bindings.kickChatMember{
                    chat_id = chat_id_str,
                    user_id = msg.from.id
                }
            end
            self.store[user.id_str] = nil
        else
            autils.strike(bot, msg, self.flag)
        end
    else
        return true
    end
end

function P:cron(_bot, _now)
    if self.last_clear ~= os.date('%H') then
        for id_str, u in pairs(self.store) do
            if os.time() > u.latest + 86400 then
                self.store[id_str] = nil
            end
        end
        self.last_clear = os.date('%H')
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
        if msg.entities then for _, entity in ipairs(msg.entities) do
            if entity.url and
                self:parse_and_detect(bot, entity.url, pattern) then
                    return true
            end
        end end
    end

    -- Iterate through all usernames in the message text, and determine if they
    -- are external group links.
    for username in msg.text:gmatch('@([%w_]+)') do
        if self:is_username_external(bot, username) then
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
    then return true end
end

 -- This function determines whether or not a given joinchat "code" refers to
 -- a group outside the realm (true/false)
function P:is_code_external(bot, code)
    -- Prepare the code to be used as a pattern by escaping any hyphens.
    -- Also, add an anchor.
    local pattern = '/' .. code:gsub('%-', '%%-') .. '$'
    -- Iterate through groups and return false if the joinchat code belongs to
    -- any one of them.
    for _, group in pairs(bot.database.administration.groups) do
        if group.link:match(pattern) then return false end
    end
    return true
end

 -- This function determines whether or not a username refers to a supergroup
 -- outside the realm (true/false).
function P:is_username_external(bot, username)
    local res = bindings.getChat{chat_id = '@' .. username}
    -- If the username is an external supergroup or channel, return true.
    if res and (res.result.type=='supergroup' or res.result.type=='channel') and
        not bot.database.administration.groups[tostring(res.result.id)] then
            return true
    end
    return false
end

return P
