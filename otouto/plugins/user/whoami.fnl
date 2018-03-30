;; whoami.fnl
;; Returns the user's or replied-to user's display name, username, and ID, in
;; addition to the group's display name, username, and ID.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "who")
    (set self.doc "Returns user and chat info for you or the replied-to message.")
    (set self.triggers (utilities.make_triggers bot [] :who :whoami))
    (values))

  :format_name (fn [user]
    (if (= (type user) :string)
      (f-str "a channel <code>[{}]</code>" (utilities.normalize_id user))
      (let [name (if user.title
                   (utilities.html_escape user.title)
                   (utilities.html_escape (utilities.build_name user.first_name user.last_name)))
            id (utilities.normalize_id user.id)]
        (if user.username
          (f-str "<b>{name}</b> (@{user.username}) <code>[{id}]</code>")
          (f-str "<b>{name}</b> <code>[{id}]</code>")))))

  :action (fn [self bot msg]
    (let [; Operate on the replied-to message, if there is one.
          msg (or msg.reply_to_message msg)
          ; If it's a private conversation, bot is chat, unless bot is from.
          chat (if (= msg.from.id msg.chat.id) bot.info msg.chat)
          new_or_left (or msg.new_chat_member msg.left_chat_member)
          output (if new_or_left
                     (f-str "{} {} {} {} {}."
                       (self.format_name msg.from)
                       (if msg.new_chat_member "added" "removed")
                       (self.format_name new_or_left)
                       (if msg.new_chat_member "to" "from")
                       (self.format_name chat))
                     ; else
                     (f-str "You are {}, and you are messaging {}."
                       (self.format_name msg.from)
                       (self.format_name chat)))]
      (utilities.send_message msg.chat.id output true msg.message_id :html)
      nil))
}
