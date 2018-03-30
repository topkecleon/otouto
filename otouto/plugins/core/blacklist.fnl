;; blacklist.lua
;; Allows the bot owner to block individuals from using the bot.

;; Load this before any plugin you want to block blacklisted users from.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities
          otouto.autils)

{
  :init (fn [self bot]
    (set self.triggers [""])
    (set self.error false)
    (set? bot.database.userdata.blacklist {}))

  :blacklist (fn [userdata]
    (if userdata.blacklist
      " is already blacklisted."
      (do
        (set userdata.blacklist true)
        " has been blacklisted.")))

  :unblacklist (fn [userdata]
    (if (not userdata.blacklist)
      " is not blacklisted."
      (do
        (set userdata.blacklist nil)
        " has been unblacklisted.")))

  :action (fn [self bot msg group user]
    (if ; non-owner is blacklisted
        (and user.data.blacklist (~= msg.from.id self.config.admin))
        nil
        ; else
        (let [act (if (: msg.text :match (f-str "^{bot.config.cmd_pat}blacklist"))
                       self.blacklist
                       (: msg.text :match (f-str "^{bot.config.cmd_pat}unblacklist"))
                       self.unblacklist
                       ; else
                       nil)]
          (if (not (and action (= msg.from.id self.config.admin)))
            :continue
            (let [targets (autils.targets bot msg)
                  output []]
              (if (not targets)
                (table.insert output bot.config.errors.specify_targets)
                (each [_ id (ipairs targets)]
                  (table.insert output
                    (if (tonumber id)
                      (let [name (utilities.lookup_name bot id)
                            ud (utilities.data_table user.data._data (tostring id))]
                        (.. name (act ud)))
                      id))))
              (utilities.send_reply msg (table.concat output "\n") :html))))))
}
