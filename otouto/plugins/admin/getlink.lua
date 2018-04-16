--[[
    getlink.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('link').table
    self.command = 'link'
    self.doc = "Returns the group link. If the group is private, \z
        only moderators may use this command and responses will be sent in private."
    self.administration = true
end

function P:action(bot, msg, group, user)
    local admin = group.data.admin
    local output
    local link = string.format(
        '<a href="%s">%s</a>',
        admin.link,
        utilities.html_escape(msg.chat.title)
    )

    -- Links to private groups are mods+ and are only PM'd.
    if admin.flags.private then
        if user:rank(bot, msg.chat.id) > 1 then
            if utilities.send_message(msg.from.id, link, true, nil, 'html') then
                output = 'I have sent you the requested information in a private message.'
            else
                output = "This group is private. The link must be received privately. \z
                    Please message me privately and re-run the command."
            end
        else
            output = 'This group is private. Only moderators may retrieve its link.'
        end
    else
        output = link
    end

    utilities.send_message(msg.chat.id, output, true, msg.message_id, 'html')
end

return P
