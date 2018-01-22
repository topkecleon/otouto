--[[
    drua-tg.lua
    Based on JuanPotato's lua-tg (https://github.com/juanpotato/lua-tg),
    modified to work more naturally from an API bot.

    Usage:
        drua = require('drua-tg')
        drua.IP = 'localhost'
        drua.PORT = 4567
        drua.message(chat_id, text)

    To run multiple commands on the same TCP session:
        s = drua.sopen()
        drua.message(chat_id, text, s)
        drua.send_photo(chat_id, filename, s)
        s:close()

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

local socket = require('socket')

local comtab = {
    add = { 'chat_add_user %s %s', 'channel_invite %s %s' },
    kick = { 'chat_del_user %s %s', 'channel_kick %s %s' },
    rename = { 'rename_chat %s "%s"', 'rename_channel %s "%s"' },
    link = { 'export_chat_link %s', 'export_channel_link %s' },
    photo_set = { 'chat_set_photo %s %s', 'channel_set_photo %s %s' },
    photo_get = { [0] = 'load_user_photo %s', 'load_chat_photo %s', 'load_channel_photo %s' },
    info = { [0] = 'user_info %s', 'chat_info %s', 'channel_info %s' }
}

local function format_target(target)
    target = tonumber(target)
    if target < -1000000000000 then
        target = 'channel#' .. math.abs(target) - 1000000000000
        return target, 2
    elseif target < 0 then
        target = 'chat#' .. math.abs(target)
        return target, 1
    else
        target = 'user#' .. target
        return target, 0
    end
end

local function escape(text)
    text = text:gsub('\\', '\\\\')
    text = text:gsub('\n', '\\n')
    text = text:gsub('\t', '\\t')
    text = text:gsub('"', '\\"')
    return text
end

local drua = {
    IP = 'localhost',
    PORT = 4567
}

function drua.sopen()
    local s = socket.connect(drua.IP, drua.PORT)
    assert(s, '\nUnable to connect to tg session.')
    return s
end

function drua.simple(command, do_receive, s)
    s:send(command..'\n')
    local output
    if do_receive then
        output = string.match(s:receive('*l'), 'ANSWER (%d+)')
        output = s:receive(tonumber(output)):gsub('\n$', '')
        s:receive('*l')
    end
    return output
end

function drua.send(command, do_receive, s)
    if s then
        return drua.simple(command, do_receive, s)
    else
        s = drua.sopen()
        local output = drua.simple(command, do_receive, s)
        s:close()
        return output
    end
end

function drua.message(target, text, s)
    target = format_target(target)
    text = escape(text)
    local command = 'msg %s "%s"'
    command = command:format(target, text)
    return drua.send(command, nil, s)
end

function drua.send_photo(target, photo, s)
    target = format_target(target)
    local command = 'send_photo %s %s'
    command = command:format(target, photo)
    return drua.send(command, nil, s)
end

function drua.add_user(chat, target, s)
    local a
    chat, a = format_target(chat)
    target = format_target(target)
    local command = comtab.add[a]:format(chat, target)
    return drua.send(command, nil, s)
end

function drua.kick_user(chat, target, s)
    -- Get the group info so tg will recognize the target.
    drua.get_info(chat, nil, s)
    local a
    chat, a = format_target(chat)
    target = format_target(target)
    local command = comtab.kick[a]:format(chat, target)
    return drua.send(command, nil, s)
end

function drua.rename_chat(chat, name, s)
    local a
    chat, a = format_target(chat)
    local command = comtab.rename[a]:format(chat, name)
    return drua.send(command, nil, s)
end

function drua.export_link(chat, s)
    local a
    chat, a = format_target(chat)
    local command = comtab.link[a]:format(chat)
    return drua.send(command, true, s)
end

function drua.get_photo(chat, s)
    local a
    chat, a = format_target(chat)
    local command = comtab.photo_get[a]:format(chat)
    local output = drua.send(command, true, s)
    if output:match('FAIL') then
        return false
    else
        return output:match('Saved to (.+)')
    end
end

function drua.set_photo(chat, photo, s)
    local a
    chat, a = format_target(chat)
    local command = comtab.photo_set[a]:format(chat, photo)
    return drua.send(command, nil, s)
end

function drua.get_info(target, s)
    local a
    target, a = format_target(target)
    local command = comtab.info[a]:format(target)
    return drua.send(command, true, s)
end

function drua.channel_set_admin(chat, user, rank, s)
    chat = format_target(chat)
    user = format_target(user)
    rank = rank or 2
    local command = 'channel_set_admin %s %s %s'
    command = command:format(chat, user, rank)
    return drua.send(command, nil, s)
end

function drua.channel_set_about(chat, text, s)
    chat = format_target(chat)
    text = escape(text)
    local command = 'channel_set_about %s "%s"'
    command = command:format(chat, text)
    return drua.send(command, nil, s)
end

function drua.block(user, s)
    return drua.send('block_user user#' .. user, nil, s)
end

function drua.unblock(user, s)
    return drua.send('unblock_user user#' .. user, nil, s)
end

function drua.get_self(s)
    return drua.send('get_self', true, s)
end

function drua.resolve_username(username, s)
    username = username:gsub('^@', '')
    return drua.send('resolve_username ' .. username, true, s)
end

return drua
