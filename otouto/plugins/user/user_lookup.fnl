;; user_lookup.fnl
;; Returns cached user info, if any, for the given targets.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities
    otouto.autils)

{
    :init (fn [self bot]
        (set self.command "lookup")
        (set self.doc "Returns stored user info, if any, for the given users.")
        (set self.triggers (utilities.make_triggers bot [] [:lookup true]))
        (set self.targeting true)
        (values))

    :action (fn [self bot msg]
        (let [(targets output) (autils.targets bot msg)]
            (if targets (utilities.merge_arrs output (utilities.list_names bot targets)))
            (utilities.send_reply msg (table.concat output "\n") "html")))
}
