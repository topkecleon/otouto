local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local antilink = {}

function antilink:init()
    assert(self.named_plugins.flags, antilink.name .. ' requires flags')
    antilink.flag_desc = 'Posting links to other groups is not allowed.'
    self.named_plugins.flags.flags[antilink.name] = antilink.flag_desc

    antilink.help_word = 'antilink'
    antilink.doc = "\z
antilink checks links and usernames posted by non-moderators. If a message \z
references a group or channel outside the realm, an automoderation strike is \z
issued (see /help automoderation) and the user's global antilink counter is \z
incremented. When his counter reaches 3, he is globally banned and \z
immediately removed from all groups where antilink was triggered. \
antilink can be enabled with /flag antilink (see /help flags)."

    -- Build the antilink patterns. Additional future domains can be added to
    -- this list to keep it up to date.
    antilink.patterns = {}
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
        table.insert(antilink.patterns, s)
    end
    antilink.triggers = utilities.clone_table(antilink.patterns)
    table.insert(antilink.triggers, '@[%w_]+')

    -- Infractions are stored, and users are globally banned after three within
    -- one day of each other.
    if not self.database.administration.antilink then
        self.database.administration.antilink = {}
    end
    antilink.store = self.database.administration.antilink

    antilink.administration = true
end

function antilink:action(msg, group, user)
    if not group.flags.antilink then return true end
    if user.rank > 1 then return true end
    if msg.forward_from and (
        (msg.forward_from.id == self.info.id) or
        (msg.forward_from.id == self.config.log_chat) or
        (msg.forward_from.id == self.config.administration.log_chat)
    ) then
        return true
    end
    if antilink.check(self, msg) then
        antilink.store[user.id_str] = antilink.store[user.id_str] or {
            count = 0,
            groups = {},
        }
        antilink.store[user.id_str].count = antilink.store[user.id_str].count +1
        antilink.store[user.id_str].groups[tostring(msg.chat.id)] = true
        antilink.store[user.id_str].latest = os.time()

        if antilink.store[user.id_str].count == 3 then
            self.database.administration.hammers[user.id_str] = true
            bindings.deleteMessage{ chat_id = msg.chat.id,
                message_id = msg.message_id }
            autils.log(self, {
                chat_id = not group.flags.private and msg.chat.id,
                target = msg.from.id,
                action = 'Globally banned',
                source = antilink.name, -- lol
                reason = antilink.flag_desc
            })
            for chat_id_str in pairs(antilink.store[user.id_str].groups) do
                bindings.kickChatMember{
                    chat_id = chat_id_str,
                    user_id = msg.from.id
                }
            end
            antilink.store[user.id_str] = nil
        else
            autils.strike(self, msg, antilink.name)
        end
    else
        return true
    end
end

function antilink:cron() -- luacheck: ignore self
    if antilink.last_clear ~= os.date('%H') then
        for id_str, u in pairs(antilink.store) do
            if os.time() > u.latest + 86400 then
                antilink.store[id_str] = nil
            end
        end
        antilink.last_clear = os.date('%H')
    end
end

antilink.edit_action = antilink.action

 -- Links can come from the message text or from entities, and can be joinchat
 -- links (t.me/joinchat/abcdefgh), username links (t.me/abcdefgh), or usernames
 -- (@abcdefgh).
function antilink.check(self, msg)
    for _, pattern in pairs(antilink.patterns) do

        -- Iterate through links in the message, and determine if they refer to
        -- external groups.
        for link in msg.text:gmatch(pattern..'%g*') do
            if antilink.parse_and_detect(self, link, pattern) then
                return true
            end
        end

        -- Iterate through the messages's entities, if any, and determine if
        -- they're links to external groups.
        if msg.entities then for _, entity in ipairs(msg.entities) do
            if entity.url and
                antilink.parse_and_detect(self, entity.url, pattern) then
                    return true
            end
        end end
    end

    -- Iterate through all usernames in the message text, and determine if they
    -- are external group links.
    for username in msg.text:gmatch('@([%w_]+)') do
        if antilink.is_username_external(self, username) then
            return true
        end
    end
end

 -- This function takes a link or username (parsed from a message or found in an
 -- entity) and returns true if that link or username refers to a supergroup
 -- outside of the realm.
function antilink.parse_and_detect(self, link, pattern)
    local code = link:match(pattern .. -- /joinchat/ABC-def_123
        '/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/([%w_%-]+)')
    local username = link:match(pattern .. '/([%w_]+)')
    if (code and antilink.is_code_external(self, code)) or
        (username and antilink.is_username_external(self, username))
    then return true end
end

 -- This function determines whether or not a given joinchat "code" refers to
 -- a group outside the realm (true/false)
function antilink.is_code_external(self, code)
    -- Prepare the code to be used as a pattern by escaping any hyphens.
    -- Also, add an anchor.
    local pattern = '/' .. code:gsub('%-', '%%-') .. '$'
    -- Iterate through groups and return false if the joinchat code belongs to
    -- any one of them.
    for _, group in pairs(self.database.administration.groups) do
        if group.link:match(pattern) then return false end
    end
    return true
end

 -- This function determines whether or not a username refers to a supergroup
 -- outside the realm (true/false).
function antilink.is_username_external(self, username)
    local res = bindings.getChat{chat_id = '@' .. username}
    -- If the username is an external supergroup or channel, return true.
    if res and (res.result.type=='supergroup' or res.result.type=='channel') and
        not self.database.administration.groups[tostring(res.result.id)] then
            return true
    end
    return false
end

return antilink
