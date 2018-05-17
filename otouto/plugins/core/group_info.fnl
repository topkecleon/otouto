; group_info.fnl
; Stores group info in database.groupdata.info.
; Also logs changes of the names of administrated groups.

; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.autils)

{
  :triggers [""]
  :error false

  :init (fn [_ bot] (tset? bot.database.groupdata :info {}))

  :action (fn [_ bot msg group]
    (when group (if (and group.data.admin
                        (not group.data.admin.flags.private)
                        group.data.info
                        (~= msg.chat.title group.data.info.title))
                  (autils.log bot {
                    :chat_id msg.chat.id
                    :action "Title changed."
                    :reason msg.chat.title
                    :source_user (if msg.new_chat_title msg.from)}))
      (set group.data.info msg.chat))
    :continue)

  :list {
    :name :groups
    :title "Known Groups"
    :type :groupdata
    :key :info
    :sudo true
  }
}
