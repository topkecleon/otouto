--[[
    paged_lists.lua
    Support for inline buttons and expiration for paged lists.
]]

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.kb = utilities.keyboard('inline_keyboard'):row()
        :button('◀', 'callback_data', self.name .. ' prev')
        :button('▶', 'callback_data', self.name .. ' next')
        :button('🗑', 'callback_data', self.name .. ' del'):serialize()

    bot.database.paged_lists = bot.database.paged_lists or {}
    self.db = bot.database.paged_lists
    self.plen = bot.config.page_length
end

 -- Send a page, store the list, and schedule it for expiration.
function P:list(bot, msg, array, title)
    local list = {
        title = title,
        array = array,
        chat_id = msg.chat.id,
        command_id = msg.message_id,
        owner = msg.from,
        page = 1
    }

    local success, result = bindings.sendMessage{
        chat_id = list.chat_id,
        text = self:page(list),
        parse_mode = 'html',
        disable_web_page_preview = true,
        reply_markup = self:count(list) > 1 and self.kb or nil
    }

    if success then
        list.message_id = result.result.message_id
        self.db[tostring(list.message_id)] = list
        bot:do_later(self.name, os.time() + 3600, list.message_id)
    end
    return success, result
end

function P:page(list)
    local output = {}
    if list.title then
        table.insert(
            output,
            '<b>' .. utilities.html_escape(list.title) .. '</b>'
        )
    end
    local last = list.page * self.plen
    table.insert(
        output,
        '• ' .. table.concat(
            table.move(list.array, last - self.plen + 1, last, 1, {}),
            '\n• '
        )
    )
    if self:count(list) > 1 then
        table.insert(
            output,
            string.format(
                '\nPage %d of %d | %d total',
                list.page,
                math.ceil(#list.array / self.plen),
                #list.array
            )
        )
    end
    return table.concat(output, '\n')
end

 -- Page count for a given list.
function P:count(list)
    return math.ceil(#list.array / self.plen)
end

function P:callback_action(_, query)
    local list = self.db[tostring(query.message.message_id)]
    if query.from.id ~= list.owner.id then
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
            if list.chat_id ~= list.owner_id then
                bindings.deleteMessage{
                    chat_id = list.chat_id,
                    message_id = list.command_id
                }
            end
            self.db[tostring(query.message.message_id)] = nil

        elseif self:count(list) == 1 then
            bindings.answerCallbackQuery{callback_query_id = query.id}
        else
            if command == 'next' then
                if list.page == self:count(list) then
                    list.page = 1
                else
                    list.page = list.page + 1
                end
            elseif command == 'prev' then
                if list.page == 1 then
                    list.page = self:count(list)
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
                reply_markup = self:count(list) > 1 and self.kb or nil
            }
        end
    end
end

function P:later(_, list_id)
    local list = self.db[tostring(list_id)]
    if list then
        bindings.deleteMessage{
            chat_id = list.chat_id,
            message_id = list.message_id
        }
        if list.chat_id ~= list.owner_id then
            bindings.deleteMessage{
                chat_id = list.chat_id,
                message_id = list.command_id
            }
        end
        self.db[tostring(list_id)] = nil
    end
end

return P
