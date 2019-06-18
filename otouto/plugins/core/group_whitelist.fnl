; group_whitelist.fnl
; Basic whitelisting for groups. The group is whitelisted when the bot is added
; by one of its administrators. The group is unwhitelisted when the bot is
; removed. The bot will leave non-whitelisted groups.

; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* extern.bindings)

{
  :init (fn [_ bot] (set? bot.database.groupdata.whitelisted {}))
  :triggers [""]
  :error false

  :action (fn [_ bot msg group user]
    (if (not group) :continue
      ;else
      (do (if (and msg.left_chat_member (= msg.left_chat_member.id bot.info.id))
                (set group.data.whitelisted nil)
              (and msg.new_chat_member
                  (= msg.new_chat_member.id bot.info.id)
                  (> (: user :rank bot) 3))
                    (set group.data.whitelisted true))
          (if (or group.data.whitelisted group.data.admin)
                :continue
              (bindings.leaveChat {:chat_id msg.chat.id})))))

  :list {
    :name :whitelist
    :title "Whitelisted Groups"
    :type :groupdata
    :key :whitelisted
    :sudo true
  }
}
