--[[
    disable_plugins.lua
    This plugin manages the list of disabled plugins for a group. Put this
    anywhere in the plugin ordering.

    Copyright 2017 bb010g <bb010g@gmail.com>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local disable_plugins = {}

function disable_plugins:init()
    disable_plugins.command = 'disable <plugin>…'
    disable_plugins.triggers =
        utilities.triggers(self.info.username, self.config.cmd_pat):t('enable', true):t('disable', true).table
    disable_plugins.doc = self.config.cmd_pat .. [[(enable|disable) <plugin>…
Sets whether plugins are enabled or disabled in a group. You must have ban permissions to use this.

If no plugins are provided, currently disabled plugins are listed.]]
end

local function get_disabled_ps(disabled_plugins, chat_id)
    local disabled_ps = disabled_plugins[tostring(chat_id)]
    if not disabled_ps then
        disabled_ps = {}
        disabled_plugins[tostring(chat_id)] = disabled_ps
    end
    return disabled_ps
end

disable_plugins.blacklist = {
    about = true,
    blacklist = true,
    control = true,
    disable_plugins = true,
    end_forwards = true,
    luarun = true,
    users = true,
}

local function toggle_ps(disabled_plugins, named_plugins, enable, plugins_str)
    local blacklist = disable_plugins.blacklist
    local disabled = {}
    local enabled = {}
    local not_found = {}
    local blacklisted = {}
    for pname in string.gmatch(plugins_str, '%S+') do
        if not named_plugins[pname] then
            table.insert(not_found, pname)
        elseif blacklist[pname] then
            table.insert(blacklisted, pname)
        elseif enable and disabled_plugins[pname] then
            disabled_plugins[pname] = nil
            table.insert(enabled, pname)
        elseif not enable and not disabled_plugins[pname] then
            disabled_plugins[pname] = true
            table.insert(disabled, pname)
        end
    end
    return disabled, enabled, not_found, blacklisted
end

function disable_plugins:action(msg)
    local chat_id = msg.chat.id
    local input = utilities.input_from_msg(msg)
    local disabled_plugins = get_disabled_ps(self.database.disabled_plugins, chat_id)
    if not input then
        local disabled = {}
        for pname, _ in pairs(disabled_plugins) do
            table.insert(disabled, pname)
        end
        if not disabled[1] then
            utilities.send_message(chat_id, 'All plugins are enabled.')
        else
            local output = '<b>Disabled plugins:</b>\n• ' .. table.concat(disabled, '\n• ')
            utilities.send_message(chat_id, output, true, nil, 'html')
        end
    else
        local chat_member = bindings.getChatMember{chat_id = chat_id, user_id = msg.from.id}.result
        if not (chat_member.status == 'creator' or chat_member.can_restrict_members) then
            utilities.send_message(chat_id, 'You need ban permissions.')
            return
        end

        local enable = (msg.text_lower:match('^'..self.config.cmd_pat..'enable') and true) or false
        local disabled, enabled, not_found, blacklisted =
            toggle_ps(disabled_plugins, self.named_plugins, enable, input)
        if next(disabled_plugins) == nil then
            self.database.disabled_plugins[tostring(chat_id)] = nil
        end
        local output = {}
        if blacklisted[1] then
            table.insert(output, '<b>Blacklisted:</b> ' .. table.concat(blacklisted, ', '))
        end
        if disabled[1] then
            table.insert(output, '<b>Disabled:</b> ' .. table.concat(disabled, ', '))
        end
        if enabled[1] then
            table.insert(output, '<b>Enabled:</b> ' .. table.concat(enabled, ', '))
        end
        if not_found[1] then
            table.insert(output, '<b>Not found:</b> ' .. table.concat(not_found, ', '))
        end
        if not output[1] then
            output[1] = 'Nothing changed.'
        end
        utilities.send_message(chat_id, table.concat(output, '\n'), true, nil, 'html')
    end
end

return disable_plugins
