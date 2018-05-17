--[[
    paged_lists.lua
    Support for inline buttons and expiration for paged lists.

    This has become such a convoluted piece of code. Here's a quick rundown.
    P:send stores a list object and generates a page (via P:page) and sends it,
    schedules it for deletion (P:later), and returns its results.
    P:action is for local admins (with can_edit_info perm) to configure page
    length, list duration, and whether (most) lists are sent in private.
    P:callback_action is to handle keyboard events on paged lists, such as
    scrolling (generating a new page with P:page) and deleting the keyboard.

    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local anise = require('extern.anise')

local P = {}

function P:init(bot)
    self.kb = {}
    self.kb.default = utilities.keyboard('inline_keyboard'):row()
        :button('◀', 'callback_data', self.name .. ' prev')
        :button('▶', 'callback_data', self.name .. ' next')
        :button('🗑', 'callback_data', self.name .. ' del'):serialize()

    self.kb.private = utilities.keyboard('inline_keyboard'):row()
        :button('◀', 'callback_data', self.name .. ' prev')
        :button('▶', 'callback_data', self.name .. ' next'):serialize()

    bot.database.paged_lists = bot.database.paged_lists or {}
    bot.database.groupdata.plists = bot.database.groupdata.plists or {}
    bot.database.userdata.plists = bot.database.userdata.plists or {}
    self.db = bot.database.paged_lists

    self.default = bot.config.paged_lists

    do -- somewhat consistent message width, kinda gross, really sorry
        local t = {}
        local spacer = '⠀'
        for _ = 1, 20 do
            table.insert(t, spacer)
        end
        self.blank = table.concat(t, spacer)
    end

    -- P.action will let local admins with can_change_info configure the length
    -- of pages, duration of lists, and whether or not lists will be sent
    -- publicly or privately.
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('listconf', true):t('plists', true).table
    self.command = 'listconf <key [value]>'
    self.doc = ("Change a setting for paged lists in the group. You must have \z
        permission to edit group info to use this command. \n\n\z
        <b>Settings</b> (defaults parenthesized): \n\z
            • length (%s) - The number of items per page. \n\z
            • duration (%s) - The period of time after a list is created \z
                that its keyboard should expire. This may be a number of \z
                seconds or an interval in the tiem format (see /help tiem). \n\z
            • private (%s) - Whether (most) lists should be sent \z
                in private rather than to the group. This can be set to \z
                <i>true</i> or <i>false</i>. \n\n\z
        If no setting is given, this text is returned. If a setting is named \z
        without a value, its current value will be returned.")
        :format(
            self.default.page_length,
            utilities.tiem.print(self.default.list_duration),
            tostring(self.default.private_lists)
        )
end

 -- Send a page, store the list, and schedule it for expiration.
 -- title and chat_id are optional. chat_id defaults to msg.chat.id unless
 -- private_lists is set.
function P:send(bot, msg, array, title, chat_id)
    local plists =
        bot.database.groupdata.plists[tostring(chat_id or msg.chat.id)] or {}

    if not chat_id then
        -- private_lists can be true, false, or nil.
        -- True or false overrides the global default, nil does not.
        if
            plists.private_lists == true
            or plists.private_lists == nil and self.default.private_lists
        then
            chat_id = msg.from.id
            plists = {}
        else
            chat_id = msg.chat.id
        end
    end

    local list = {
        array = array,
        title = title,
        chat_id = chat_id,
        owner = msg.from,
        page = 1,
        page_length = plists.page_length or self.default.page_length
    }
    list.page_count = math.ceil(#list.array / list.page_length)
    if list.page_count <= 1 then
        list.kb = nil
    elseif list.owner.id == list.chat_id then
        list.kb = 'private'
    else
        list.kb = 'default'
    end

    local success, result = bindings.sendMessage{
        chat_id = list.chat_id,
        text = self:page(list),
        parse_mode = 'html',
        disable_web_page_preview = true,
        reply_markup = self.kb[list.kb]
    }

    if success then
        list.message_id = result.result.message_id
        self.db[tostring(list.message_id)] = list
        bot:do_later(
            self.name,
            os.time() + (plists.list_duration or self.default.list_duration),
            list.message_id
        )
    end
    return success, result
end

 -- Generate a page.
function P:page(list)
    local output = {}
    if list.title then
        table.insert(
            output,
            '<b>' .. utilities.html_escape(list.title) .. '</b>'
        )
    end

    local last = list.page * list.page_length
    if #list.array == 0 then
        table.insert(output, '<i>This list is empty!</i>')
    else
        table.insert(
            output,
            '• ' .. table.concat(
                table.move(list.array, last - list.page_length + 1, last, 1, {}),
                '\n• '
            )
        )
    end

    if list.page_count > 1 then
        table.insert(output, self.blank)
        table.insert(
            output,
            string.format(
                '<code>Page %d of %d | %d total</code>',
                list.page,
                list.page_count,
                #list.array
            )
        )
    end

    return table.concat(output, '\n')
end

 -- For P.action
P.conf = {
    length = function(plists, num)
        if not num then
            return plists.page_length
        elseif tonumber(num) then
            num = math.floor(math.abs(tonumber(num)))
            if num < 1 or num > 40 then
                return 'The range for page length is 1-40.'
            else
                plists.page_length = num
                return 'Page length is now ' .. num .. '.'
            end
        else
            return 'Page length must be a number.'
        end
    end,

    duration = function(plists, dur)
        if not dur then
            return utilities.tiem.print(plists.list_duration)
        elseif utilities.tiem.deformat(dur) then
            local interval = utilities.tiem.deformat(dur)
            if interval < 60 or interval > 86400 then
                return 'The range for list duration is one minute through one day.'
            else
                plists.list_duration = interval
                return 'The list duration is now ' ..
                    utilities.tiem.print(interval) .. '.'
            end
        else
            return 'The list duration must be an interval (see /help tiem).'
        end
    end,

    private = function(plists, bool)
        if not bool then
            bool = tostring(not plists.private_lists)
        end

        if bool:lower() == 'true' then
            plists.private_lists = true
            return 'Most lists will now be sent privately.'
        elseif bool:lower() == 'false' then
            plists.private_lists = false
            return 'Lists will no longer be sent privately.'
        else
            return 'This setting is true/false.'
        end
    end
}

 -- For local admins to configure paged lists in the group.
function P:action(bot, msg, group, user)
    local _, result = bindings.getChatMember{
        chat_id = msg.chat.id,
        user_id = msg.from.id
    }
    if result.result.can_change_info or result.result.status == 'creator' then
        local plists
        if group and group.data.plists then
            plists = group.data.plists
        elseif user and user.data.plists then
            plists = user.data.plists
        else
            plists = anise.clone(self.default)
        end

        local setting = utilities.get_word(msg.text:lower(), 2)
        setting = setting and setting:lower()
        if setting and self.conf[setting] then
            if group then
                group.data.plists = plists
            else
                user.data.plists = plists
            end

            local value = utilities.get_word(msg.text:lower(), 3)
            utilities.send_reply(msg, self.conf[setting](plists, value))
        else
            local output = utilities.plugin_help(bot.config.cmd_pat, self) ..
                ("\n\n<b>Current settings:</b> \n\z
                    • length - %s \n\z
                    • duration - %s \n\z
                    • private - %s"):format(
                plists.page_length,
                utilities.tiem.print(plists.list_duration),
                tostring(plists.private_lists)
            )
            utilities.send_reply(msg, output, 'html')
        end
    else
        utilities.send_reply(msg, 'You need permission to edit group info.')
    end
end

 -- For the inline keyboard buttons on lists.
function P:callback_action(_, query)
    local list = self.db[tostring(query.message.message_id)]
    if not list then -- Remove the keyboard from a list we're not storing.
        bindings.editMessageReplyMarkup{
            chat_id = query.message.chat.id,
            message_id = query.message.message_id
        }
    elseif query.from.id ~= list.owner.id then
        bindings.answerCallbackQuery{
            callback_query_id = query.id,
            text = 'Only ' .. list.owner.first_name .. ' may use this keyboard.'
        }
    else
        local command = utilities.get_word(query.data, 2)
        if command == 'del' then
            bindings.deleteMessage{
                chat_id = list.chat_id,
                message_id = list.message_id
            }
            self.db[tostring(query.message.message_id)] = nil

        elseif command == 'next' then
            if list.page == list.page_count then
                list.page = 1
            else
                list.page = list.page + 1
            end

        elseif command == 'prev' then
            if list.page == 1 then
                list.page = list.page_count
            else
                list.page = list.page - 1
            end
        end
        bindings.editMessageText{
            chat_id = list.chat_id,
            message_id = list.message_id,
            text = self:page(list),
            parse_mode = 'html',
            disable_web_page_preview = true,
            reply_markup = self.kb[list.kb]
        }
    end
end

 -- For the expiration of lists.
function P:later(_, list_id)
    local list = self.db[tostring(list_id)]
    if list then
        if list.page_count ~= 1 then
            bindings.editMessageReplyMarkup{
                chat_id = list.chat_id,
                message_id = list.message_id
            }
        end
        self.db[tostring(list_id)] = nil
    end
end

return P
