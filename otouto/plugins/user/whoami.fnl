;; whoami.fnl
;; Returns the user's or replied-to user's display name, username, and ID, in
;; addition to the group's display name, username, and ID.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "who")
    (set self.doc "Returns user and chat info for you or the replied-to message.")
    (set self.triggers (utilities.make_triggers bot [] :who :whoami))
    (values))

  :action (fn [self bot msg]
    (let [; Operate on the replied-to message, if there is one.
          msg (or msg.reply_to_message msg)
          ; If it's a private conversation, bot is chat, unless bot is from.
          chat (if (= msg.from.id msg.chat.id) bot.info msg.chat)
          new_or_left (or msg.new_chat_member msg.left_chat_member)
          output (if new_or_left
                     (f-str "{} {} {} {} {}."
                       (utilities.format_name msg.from)
                       (if msg.new_chat_member "added" "removed")
                       (utilities.format_name new_or_left)
                       (if msg.new_chat_member "to" "from")
                       (utilities.format_name chat))
                     ; else
                     (f-str "You are {}, and you are messaging {}."
                       (utilities.format_name msg.from)
                       (utilities.format_name chat)))]
      (utilities.send_message msg.chat.id output true msg.message_id :html)
      nil))
}
