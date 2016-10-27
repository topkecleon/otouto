--[[
    blacklist.lua
    Allows the bot owner to block individuals from using the bot.

    Load this before any plugin you want to block blacklisted users from.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local drua = require('otouto.drua-tg')

local blacklist = {}

function blacklist:init()
    blacklist.triggers = { '' }
    blacklist.error = false
    self.database.userdata.blacklist = self.database.userdata.blacklist or {}
end

function blacklist:add(user, s)
    if s and user.id > 0 then
        drua.block(user.id_str, s)
    end
    if self.database.userdata.blacklist[user.id_str] then
        return user.name .. ' is already blacklisted.\n'
    else
        self.database.userdata.blacklist[user.id_str] = true
        return user.name .. ' has been blacklisted.\n'
    end
end

function blacklist:remove(user, s)
    if s and user.id > 10 then
        drua.unblock(user.id_str, s)
    end
    if not self.database.userdata.blacklist[user.id_str] then
        return user.name .. ' is not blacklisted.\n'
    else
        self.database.userdata.blacklist[user.id_str] = nil
        return user.name .. ' has been unblacklisted.\n'
    end
end

function blacklist:action(msg)
    -- End if the user is blacklisted and is not the owner.
    if (
        self.database.userdata.blacklist[tostring(msg.from.id)]
        and msg.from.id ~= self.config.admin
    ) then return end
    -- Return true is the user is not the owner and has not called the plugin.
    if not (
        msg.from.id == self.config.admin
        and (
            msg.text:match('^'..self.config.cmd_pat..'blacklist')
            or msg.text:match('^'..self.config.cmd_pat..'unblacklist')
        )
    ) then return true end

    local s = self.config.drua_block_on_blacklist and drua.sopen()
    local doer = blacklist.add
    if msg.text:match('^'..self.config.cmd_pat..'unblacklist') then
        doer = blacklist.remove
    end
    local output
    if msg.reply_to_message then
        output = doer(
            self,
            {
                id = msg.reply_to_message.from.id,
                id_str = tostring(msg.reply_to_message.from.id),
                name = utilities.build_name(msg.reply_to_message.from.first_name, msg.reply_to_message.from.last_name)
            },
            s
        )
    else
        output = ''
        local input = utilities.input(msg.text)
        if input then
            for user in input:gmatch('%g+') do
                if self.database.users and self.database.users[user] then
                    output = output .. doer(
                        self,
                        {
                            id = self.database.users[user].id,
                            id_str = tostring(self.database.users[user].id),
                            name = utilities.build_name(self.database.users[user].first_name, self.database.users[user].last_name)
                        },
                        s
                    )
                elseif tonumber(user) then
                    local name
                    if tonumber(user) > 0 then
                        name = 'User (' .. user .. ')'
                    else
                        name = 'Group (' .. user .. ')'
                    end
                    output = output .. doer(
                        self,
                        {
                            id_str = user,
                            id = tonumber(user),
                            name = name
                        },
                        s
                    )
                elseif user:match('^@') then
                    local u = utilities.resolve_username(self, user)
                    if u then
                        output = output .. doer(
                            self,
                            {
                                id = u.id,
                                id_str = tostring(u.id),
                                name = utilities.build_name(u.first_name, u.last_name)
                            },
                            s
                        )
                    else
                        output = output .. 'Sorry, I do not recognize that username ('..user..').\n'
                    end
                else
                    output = output .. 'Invalid username or ID ('..user..').\n'
                end
            end
        else
            output = 'Please specify a user or users via reply, username, or ID, or a group or groups via ID.'
        end
    end
    if s then s:close() end
    utilities.send_reply(msg, output)
end

return blacklist
