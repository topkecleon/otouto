;; eightball.fnl
;; Returns magic 8-ball like answers.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          (rename otouto.plugins.user.data.eightball data))

{
  :init (fn [self bot]
    (set self.command "8ball")
    (set self.doc "Returns an answer from a magic 8-ball!")
    (set self.triggers (utilities.make_triggers bot ["[Yy]/[Nn]%p*$"] [:8ball true]))
    (values))
}
