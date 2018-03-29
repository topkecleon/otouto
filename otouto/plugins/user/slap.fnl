;; slap.fnl
;; Allows users to slap someone.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local utilities (require :otouto.utilities))
(require-macros :otouto.macros)
(local data (require :otouto.plugins.user.data.slap))

{
  :init (fn [self bot]
    (set self.command "slap [target]")
    (set self.doc "Slap somebody.")
    (set self.triggers (utilities.make_triggers bot [] [:slap true]))
    (values))

  :get_name (fn [bot user]
    (local id_str (tostring user.id))
    (local nick bot.database.userdata.nick)
    (if nick[id_str]
        nick[id_str]
        user.last_name
        (f-str "{user.first_name} {user.last_name}")
        ; else
        user.first_name))

  :action (fn [self bot msg]
    (local victor (self.get_name bot msg.from))
    (local input (utilities.input msg.text))
    (local victim (if msg.reply_to_message
                      (self.get_name bot msg.reply_to_message.from)
                      input
                      (if (= (: input :match "^@(.+)$") bot.info.username)
                          bot.info.first_name
                          (: input :match "^@.")
                          (let [user (utilities.resolve_username bot input)]
                            (if user (self.get_name bot user) input))
                          (and (tonumber input) bot.database.users bot.database.users[input])
                          (self.get_name bot bot.database.users[input])
                          ; else
                          input)
                      ; else
                      (self.get_name bot msg.from)))
    (local victor (if (= victor victim) bot.info.first_name victor))

    (let [victor (: victor :gsub "%%" "%%%%")
          victim (: victim :gsub "%%" "%%%%")
          slap (.. utilities.char.zwnj (. data (math.random (# data))))
          output (: (: slap :gsub "VICTOR" victor) :gsub "VICTIM" victim)]
      (utilities.send_message msg.chat.id output)
      nil))
}
