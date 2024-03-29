--[[
    mute.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local anise = require('anise')
local bindings = require('extern.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('mute', true).table
    self.command = 'mute'
    self.doc = "Mute a user or users indefinitely or for the time specified. \z
A duration in the tiem format (see /help tiem) can be given before the reason. \
Examples:\
    /mute @foo @bar 8675309\
    2h30m No cursing on my Christian server.\
\
    [in reply] /mute 240"
    self.privilege = 2
    self.administration = true
    self.targeting = true
    self.duration = true
end

function P:action(bot, msg, _group, _user)
    local targets, output, reason, duration =
        autils.targets(bot, msg, {get_duration = true})
    local muted_users = anise.set()

    -- Durations shorter than 30 seconds and longer than a leap year are
    -- interpreted as "forever" by the bot API.
    if duration and (duration > 366*24*60*60 or duration < 60) then
        duration = nil
        table.insert(output,
            'Durations must be longer than a minute and shorter than a year.')
    end

    local out_str, log_str
    if duration then
        out_str = ' has been muted for ' ..
            utilities.tiem.print(duration) .. '.'
        log_str = 'Muted for ' .. utilities.tiem.print(duration)
    else
        out_str = ' has been muted.'
        log_str = 'Muted'
    end

    for target, _ in pairs(targets) do
        local name = utilities.lookup_name(bot, target)

        if autils.rank(bot, target, msg.chat.id) >= 2 then
            table.insert(output,name .. ' is too privileged to be muted.')
        else
            local success, result = bindings.restrictChatMember{
                chat_id = msg.chat.id,
                user_id = target,
                until_date = duration and os.time() + duration,
                can_send_messages = false
            }
            if success then
                table.insert(output, name .. out_str)
                muted_users:add(target, reason or true)
            else
                table.insert(output, result.description .. ' (' ..target.. ')')
            end
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #muted_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = muted_users,
            action = log_str,
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
