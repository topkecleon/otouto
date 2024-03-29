;; user_lookup.fnl
;; Returns cached user info, if any, for the given targets.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* anise
          otouto.utilities
          otouto.autils)

{
  :init (fn [self bot]
    (set self.command "lookup")
    (set self.doc "Returns stored user info, if any, for the given users.")
    (set self.triggers (utilities.make_triggers bot [] [:lookup true]))
    (set self.targeting true)
    (values))

  :action (fn [self bot msg]
    (local (targets output)
        (autils.targets bot msg {:unknown_ids_err true :self_targeting true}))
    (anise.pushcat output (utilities.list_names bot targets))
    (utilities.send_reply msg (table.concat output "\n") :html)
    nil)
}
