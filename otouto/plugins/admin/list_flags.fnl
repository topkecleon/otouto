; list_flags.fnl
; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "listflags")
    (set self.doc "Returns a list of enabled and disabled flags. Governors and\z
 administrators can use /flags to configure them.")
    (set self.triggers (utilities.make_triggers bot [] "list_?flags"))
    (set self.administration true)
    (values))

  :action (fn [_self bot msg group]
    (utilities.send_reply msg
      (: (. bot.named_plugins :admin.flags) :list_flags group.data.admin.flags)
      :html))
}
