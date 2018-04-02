--[[
    utilities.lua
    Functions shared among otouto plugins.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local http = require('socket.http')
local https = require('ssl.https')
-- Global http/s timeout.
http.TIMEOUT = 10
local json = require('dkjson')
local ltn12 = require('ltn12')
local url = require('socket.url')
-- Lua 5.2 compatibility.
-- If no built-in utf8 is available, load the library.
local utf8 = utf8 or require('lua-utf8')

local bindings = require('otouto.bindings')

local utilities = {}

-- For the sake of ease to new contributors and familiarity to old contributors,
-- we'll provide a couple of aliases to real bindings here.
-- Edit: To keep things working and allow for HTML messages, you can now pass a
-- string for use_markdown and that will be sent as the parse mode.
function utilities.send_message(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)
    local parse_mode
    if type(use_markdown) == 'string' then
        parse_mode = use_markdown
    elseif use_markdown == true then
        parse_mode = 'markdown'
    end
    return bindings.request(
        'sendMessage',
        {
            chat_id = chat_id,
            text = text,
            disable_web_page_preview = disable_web_page_preview,
            reply_to_message_id = reply_to_message_id,
            parse_mode = parse_mode
        }
    )
end

function utilities.send_reply(msg, text, use_markdown)
    return utilities.send_message(msg.chat.id, text, true, msg.message_id, use_markdown)
end

-- get the indexed word in a string
function utilities.get_word(s, i)
    s = s or ''
    i = i or 1
    local n = 0
    for w in s:gmatch('%g+') do
        n = n + 1
        if n == i then return w end
    end
    return false
end

-- Returns the string after the first space.
function utilities.input(s)
    return s:match('%s+(.+)')
end

function utilities.input_from_msg(msg)
    return msg.text:match('%s+(.+)')
        or (msg.reply_to_message and #msg.reply_to_message.text > 0 and msg.reply_to_message.text)
        or false
end

-- Calculates the length of the given string as UTF-8 characters
function utilities.utf8_len(s)
    local chars = 0
    for i = 1, string.len(s) do
        local b = string.byte(s, i)
        if b < 128 or b >= 192 then
            chars = chars + 1
        end
    end
    return chars
end

-- Loads a json file as a table.
function utilities.load_data(filename)
    local f = io.open(filename)
    if f then
        local s = f:read('*all')
        f:close()
        return json.decode(s)
    else
        return {}
    end
end

-- Saves a table to a json file.
function utilities.save_data(filename, data)
    local s = json.encode(data)
    local f = io.open(filename, 'w')
    f:write(s)
    f:close()
end

-- Gets coordinates for a location. Used by gMaps.lua, time.lua, weather.lua.
-- Returns nil for a connection error and false for zero results.
function utilities.get_coords(input)
    local call_url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. url.escape(input)
    local jstr, res = http.request(call_url)
    if res ~= 200 then
        return
    end
    local jdat = json.decode(jstr)
    if not jdat then
        return
    elseif jdat.status == 'ZERO_RESULTS' or not jdat.results[1] then
        return false
    else
        return jdat.results[1].geometry.location.lat, jdat.results[1].geometry.location.lng
    end
end

-- Get the number of values in a key/value table.
function utilities.table_size(tab)
    local i = 0
    for _ in pairs(tab) do
        i = i + 1
    end
    return i
end

utilities.data_table_meta = {
    __index = function (self, key)
        local data = rawget(self, "_data")
        if data._parent then
            local val = data[key]
            return val and
                setmetatable({_data = val, _key = rawget(self, "_key")}, getmetatable(self))
        else
            local val = data[key]
            return val and val[rawget(self, "_key")]
        end
    end,
    __newindex = function (self, key, value)
        local data = rawget(self, "_data")
        if data._parent then
            error("Can't set non-terminal key " .. tostring(key) .. " in a data_table")
            return
        else
            local t = data[key]
            if t == nil then
                t = {}
                data[key] = t
            end
            t[rawget(self, "_key")] = value
            return
        end
    end,
    __pairs = function (self)
        local data = rawget(self, "_data")
        if data._parent then
            local selfmeta = getmetatable(self)
            local function iter(table, index)
                local new_index, val = next(table, index)
                if new_index then
                    return new_index, setmetatable({_data = val, _key = rawget(self, "_key")}, selfmeta)
                else
                    return nil
                end
            end
            return iter, data, nil
        else
            local function iter(table, index)
                local new_index, val = next(table, index)
                if new_index then
                    return new_index, val[rawget(self, "_key")]
                else
                    return nil
                end
            end
            return iter, data, nil
        end
    end,
    __ipairs = function (self)
        local data = rawget(self, "_data")
        if data._parent then
            local selfmeta = getmetatable(self)
            local function iter(table, i)
                i = i + 1
                local val = table[i]
                if val then
                    return i, setmetatable({_data = val, _key = rawget(self, "_key")}, selfmeta)
                else
                    return nil
                end
            end
            return iter, data, 0
        else
            local function iter(table, i)
                i = i + 1
                local val = table[i]
                if val then
                    return i, val[rawget(self, "_key")]
                else
                    return nil
                end
            end
            return iter, data, nil
        end
    end,
}
function utilities.data_table(data, key)
    return setmetatable({_data = data, _key = key}, utilities.data_table_meta)
end

-- Just an easy way to get a user's full name.
-- Alternatively, abuse it to concat two strings like I do.
function utilities.build_name(first, last)
    if last then
        return first .. ' ' .. last
    else
        return first
    end
end

function utilities.resolve_username(bot, input)
    input = input:gsub('^@', '')
    if not bot.database.userdata.info then return end
    for _, user in pairs(bot.database.userdata.info) do
        if user.username and user.username:lower() == input:lower() then
            return user
        end
    end
end

-- Log an error. If log_chat is given, send it there; if not, print it.
function utilities.log_error(text, log_chat)
    local output = string.format(
        '[%s]\n%s',
        os.date('%F %T'),
        text
    )
    if log_chat then
        return bindings.sendMessage{
            chat_id = log_chat,
            text = '<code>' .. utilities.html_escape(output) .. '</code>',
            parse_mode = 'html'
        }
    else
        print(output)
    end
end

function utilities.send_help_for(chat_id, reply_to_message_id, name, doc)
    return utilities.send_message(
        chat_id,
        "<b>Help for</b> <i>" .. utilities.html_escape(name) .. "</i><b>:</b>\n" .. doc,
        true,
        reply_to_message_id,
        'html'
    )
end

function utilities.plugin_help(cmd_pat, plugin)
    return cmd_pat .. utilities.html_escape(plugin.command) .. "\n" .. plugin.doc
end

function utilities.send_plugin_help(chat_id, reply_to_message_id, cmd_pat, plugin)
    local doc = utilities.plugin_help(cmd_pat, plugin)
    return utilities.send_help_for(chat_id, reply_to_message_id, plugin.help_word, doc)
end

function utilities.download_file(file_url, filename)
    if not filename then
        filename = os.tmpname()
    end
    local body = {}
    local doer = http
    local do_redir = true
    if file_url:match('^https') then
        doer = https
        do_redir = false
    end
    local _, res = doer.request{
        url = file_url,
        sink = ltn12.sink.table(body),
        redirect = do_redir
    }
    if res ~= 200 then return false end
    local file = io.open(filename, 'w+')
    file:write(table.concat(body))
    file:close()
    return filename
end

function utilities.md_escape(text)
    return text:gsub('_', '\\_')
               :gsub('%[', '\\[')
               :gsub('%]', '\\]')
               :gsub('%*', '\\*')
               :gsub('`', '\\`')
end

function utilities.html_escape(text)
    return text:gsub('&', '&amp;')
               :gsub('<', '&lt;')
               :gsub('>', '&gt;')
end

utilities.triggers_meta = {
    t = function (self, pattern, has_args)
        local username = self.username:lower()
        table.insert(self.table, '^'..self.cmd_pat..pattern..'$')
        table.insert(self.table, '^'..self.cmd_pat..pattern..'@'..username..'$')
        if has_args then
            table.insert(self.table, '^'..self.cmd_pat..pattern..'%s+[^%s]*')
            table.insert(self.table, '^'..self.cmd_pat..pattern..'@'..username..'%s+[^%s]*')
        end
        return self
    end
}
utilities.triggers_meta.__index = utilities.triggers_meta

function utilities.triggers(username, cmd_pat, trigger_table)
    return setmetatable({
        username = username,
        cmd_pat = cmd_pat,
        table = trigger_table or {}
    }, utilities.triggers_meta)
end

function utilities.make_triggers(bot, trigger_table, ...)
    local triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat, trigger_table)
    for _, trigger in pairs({...}) do
        if type(trigger) == 'table' then
            triggers:t(table.unpack(trigger))
        else
            triggers:t(trigger)
        end
    end
    return triggers.table
end

function utilities.pretty_float(x)
    if x % 1 == 0 then
        return tostring(math.floor(x))
    else
        return tostring(x)
    end
end

-- This table will store unsavory characters that are not properly displayed,
-- or are just not fun to type.
utilities.char = {
    zwnj = utf8.char(0x200c),
    arabic = '[\216-\219][\128-\191]',
    rtl_override = utf8.char(0x202e),
    rtl_mark = utf8.char(0x200f),
    em_dash = '—',
    utf_8 = '[%z\1-\127\194-\244][\128-\191]',
    braille_space = utf8.char(0x2800),
    invisible_separator = utf8.char(0x2063)
}

utilities.set_meta = {
    add = function (self, x)
        if x == "__count" then
            return false
        else
            if not self[x] then
                self[x] = true
                self.__count = self.__count + 1
            end
            return true
        end
    end,
    remove = function (self, x)
        if x == "__count" then
            return false
        else
            if self[x] then
                self[x] = nil
                self.__count = self.__count - 1
            end
            return true
        end
    end,
    __len = function (self)
        return self.__count
    end
}
utilities.set_meta.__index = utilities.set_meta
function utilities.new_set()
    return setmetatable({__count = 0}, utilities.set_meta)
end

-- Converts a gross string back into proper UTF-8.
-- Useful for fixing improper encoding caused by bad json escaping.
function utilities.fix_utf8(str)
    return string.char(utf8.codepoint(str, 1, -1))
end

-- The bot API changes all group, channel, and supergroup IDs.
-- User: 123456789
-- Group: -123456789
-- Channel/supergroup: -100123456789
-- This function takes an ID and returns the "real" ID, which is 123456789.
function utilities.normalize_id(id)
    local out = math.abs(tonumber(id))
    return out > 1000000000000 and out - 1000000000000 or out
end

-- returns "<b>$fullname</b> <code>[$id]</code> ($username)"
function utilities.format_name(user) -- or chat
    return (string.format(
        '%s <code>[%s]</code>%s',
        utilities.html_escape(
            user.title or utilities.build_name(user.first_name, user.last_name)
        ),
        utilities.normalize_id(user.id),
        user.username and ' <i>@' .. user.username .. '</i>' or ''
    ):gsub(utilities.char.rtl_override, ''):gsub(utilities.char.rtl_mark, ''))
end

function utilities.lookup_user(bot, id)
    return
        (bot.database.userdata.info
            and bot.database.userdata.info[tostring(id)])
        or (bot.database.groupdata.info
            and bot.database.groupdata.info[tostring(id)])
        or { id = id, first_name = 'Unknown' }
end

-- format_name with lookup_user
function utilities.lookup_name(bot, id)
    return utilities.format_name(utilities.lookup_user(bot, id))
end

-- Takes a set of ID (id_str because set), eg a userdata table or a mod list,
-- and return an array of their formatted names.
function utilities.list_names(bot, ids)
    local t = {}
    for id in pairs(ids) do
        table.insert(t, utilities.lookup_name(bot, id))
    end
    return t
end

function utilities.divmod(x, y)
    local q = math.floor(x / y)
    return q, x - y * q
end

-- named by brayden
utilities.tiem = {
    order = { 'y', 'w', 'd', 'h', 'm', 's' },
    dict = {
        y = 365.25 * 86400,
        w = 7 * 86400,
        d = 86400,
        h = 3600,
        m = 60,
        s = 1
    },
    pretty = {
        y = 'year',
        w = 'week',
        d = 'day',
        h = 'hour',
        m = 'minute',
        s = 'second'
    },
    format = function (seconds, pretty)
        local output = {}
        for _, l in ipairs(utilities.tiem.order) do
            local v = utilities.tiem.dict[l]
            if seconds >= v then
                local q, r = utilities.divmod(seconds, v)
                if pretty then
                    table.insert(output, string.format('%s %s%s',
                        q, utilities.tiem.pretty[l], q == 1 and '' or 's'))
                else
                    table.insert(output, q .. l)
                end
                seconds = r
            end
        end
        return table.concat(output, pretty and ', ')
    end,
    deformat = function (time_str)
        if
            (not time_str:match('^[%dywdhms]+$'))
            or time_str:match('%l%l')
            or time_str:match('^%l')
            or time_str:match('%d$')
        then
            return false
        end

        local seconds = 0
        for num, typ in time_str:lower():gmatch('(%d+)(%l)') do
            seconds = seconds + num * utilities.tiem.dict[typ]
        end
        return math.floor(seconds)
    end,
}

-- Merges arrays into the first.
-- Distinct from lume.concat because the latter creates a new array.
function utilities.merge_arrs(base, ...)
    local size = #base
    for i = 1, select('#', ...) do
        local arr = select(i, ...)
        if arr then
            for j = 1, #arr do
                size = size + 1
                base[size] = arr[j]
            end
        end
    end
end

return utilities
