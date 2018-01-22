local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local antilink = {}

function antilink:init()
    assert(self.named_plugins.flags, antilink.name .. ' requires flags')
    self.named_plugins.flags.flags[antilink.name] =
        'Posting links to foreign Telegram groups is not allowed.'
        
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
    antilink.triggers = antilink.patterns
    antilink.internal = true
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
        autils.strike(self, msg, antilink.name)
    else
        return true
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
    if res and res.result.type =='supergroup' or res.result.type =='channel' and
        not self.database.administration.groups[tostring(res.result.id)] then
            return true
    end
    return false
end

return antilink
