local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('description', true):t('desc', true).table
    P.command = 'description [chat]'
end

function P:action(msg, group, user)
    local input = utilities.input(msg.text_lower)
    local chat_id
    if input then
        for id_str, group in pairs(self.database.administration.groups) do
            if not group.flags.private and group.name:lower():match(input) then
                chat_id = id_str
                break
            end
        end
        if not chat_id then
            utilities.send_reply(msg, 'Group not found.')
            return
        end
    elseif group then
        chat_id = msg.chat.id
    else
        utilities.send_reply(msg, 'Specify a group.')
        return
    end

    local description = P.desc(self, chat_id)

    if msg.chat.id == msg.from.id then
        utilities.send_reply(msg, description, 'html')
    else
        if utilities.send_message(msg.from.id, description, true, nil, 'html') then
            utilities.send_reply(msg, 'I have sent you the requested information in a private message.')
        else
            utilities.send_reply(msg, description, 'html')
        end
    end
end

function P:desc(chat_id)
    local group = self.database.administration.groups[tostring(chat_id)]

    local output = '<b>Welcome to '
    if group.flags.private then
        output = output .. utilities.html_escape(group.name) .. '!</b>'
    else
        output = output .. '</b><a href="' .. group.link .. '">' ..
            utilities.html_escape(group.name) .. '</a><b>!</b>'
    end

    output = output ..' <code>['.. utilities.normalize_id(chat_id) .. ']</code>'

    if group.description then
        output = output .. '\n\n' .. group.description
    end

    if #group.rules > 0 then
        output = output .. '\n\n<b>Rules:</b>'
        for i, rule in ipairs(group.rules) do
            output = output .. '\n<b>' .. i .. '.</b> ' .. rule
        end
    end

    if next(group.flags) ~= nil then
        output = output .. '\n\n<b>Flags:</b>'
        for flag in pairs(group.flags) do
            output = output .. '\n• ' .. self.named_plugins.flags.flags[flag]
        end
    end

    output = output .. '\n\n<b>Governor:</b> ' ..
        utilities.format_name(self, group.governor)

    if next(group.moderators) ~= nil then
        output = output .. '\n\n<b>Moderators:</b>'
        for id in pairs(group.moderators) do
            output = output .. '\n• ' .. utilities.format_name(self, id)
        end
    end

    return output
end

return P
