;; blacklist.lua
;; Allows the bot owner to block individuals from using the bot.

;; Load this before any plugin you want to block blacklisted users from.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          otouto.autils)

{
  :init (fn [self bot]
    (set self.triggers [""])
    ;(set self.error false)
    (tset? bot.database.userdata :blacklisted {}))

  :blacklist (fn [userdata]
    (if userdata.blacklisted
      " is already blacklisted."
      (do
        (set userdata.blacklisted true)
        " has been blacklisted.")))

  :unblacklist (fn [userdata]
    (if (not userdata.blacklisted)
      " is not blacklisted."
      (do
        (set userdata.blacklisted nil)
        " has been unblacklisted.")))

  :action (fn [self bot msg _ user]
    (if ; non-owner is blacklisted
        (and user.data.blacklisted (~= msg.from.id bot.config.admin))
        nil
        ; else
        (let [act (if (: msg.text :match (f-str "^{bot.config.cmd_pat}blacklist"))
                       self.blacklist
                       (: msg.text :match (f-str "^{bot.config.cmd_pat}unblacklist"))
                       self.unblacklist
                       ; else
                       nil)]
          (if (not (and act (= msg.from.id bot.config.admin)))
                :continue
              (let [(targets errors) (autils.targets bot msg)]
                (each [target (pairs targets)]
                  (table.insert errors
                    (let [user (utilities.user bot target)]
                      (.. (: user :name) (act user.data)))))
                (utilities.send_reply msg (table.concat errors "\n") :html))))))
}
