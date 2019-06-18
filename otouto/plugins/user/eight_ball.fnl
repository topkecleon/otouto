;; eight_ball.fnl
;; Returns magic 8-ball like answers.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          (rename otouto.plugins.user.data.eight_ball data))

{ :init
  (fn [self bot]
   (set self.command "8ball")
   (set self.doc "Returns an answer from a magic 8-ball!")
   (set self.triggers (utilities.make_triggers bot ["[Yy]/[Nn]%p*$"] [:8ball true]))
   (values))

  :action
  (fn [self _ msg]
    (utilities.send_reply
      msg
      (and-or (: msg.text_lower :match "y/n%p?$")
              (. data.yesno (math.random (# data.yesno)))
              (. data.answers (math.random (# data.answers))))))}

