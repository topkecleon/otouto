;; slap.fnl
;; Allows users to slap someone.

;; Copyright 2019 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          (rename otouto.plugins.user.data.slap data))

{
  :init (fn [self bot]
    (set self.command "slap [target]")
    (set self.doc "Slap somebody.")
    (set self.triggers (utilities.make_triggers bot [] [:slap true]))
    (values))

  :action (fn [self bot msg]
    (local victor (utilities.get_nick bot msg.from))
    (local input (utilities.input msg.text))
    (local users bot.database.userdata.info)
    (local victim (if msg.reply_to_message
                      (utilities.get_nick bot msg.reply_to_message.from)
                      input
                      (if (= (: input :match "^@(.+)$") bot.info.username)
                          bot.info.first_name
                          (: input :match "^@.")
                          (let [user (utilities.resolve_username bot input)]
                            (if user (utilities.get_nick bot user) input))
                          (and (tonumber input) users users[input])
                          (utilities.get_nick bot users[input])
                          ; else
                          input)
                      ; else
                      (utilities.get_nick bot msg.from)))
    (local victor (if (= victor victim) bot.info.first_name victor))

    (let [victor (: victor :gsub "%%" "%%%%")
          victim (: victim :gsub "%%" "%%%%")
          slap (.. utilities.char.zwnj (. data (math.random (# data))))
          output (: (: slap :gsub "VICTOR" victor) :gsub "VICTIM" victim)]
      (utilities.send_message msg.chat.id output)
      nil))
}
