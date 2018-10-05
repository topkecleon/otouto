;; dice.fnl
;; Returns a set of random numbers. Accepts D&D notation.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "roll <nDr>")
    (set self.doc
      "Returns a set of dice rolls, where <i>n</i> is the number of rolls and <i>r</i> is the \z
       range. If only a range is given, returns only one roll.")
    (set self.triggers (utilities.make_triggers bot [] [:roll true]))
    (values))

  :action (fn [self bot msg]
    (local input (utilities.input msg.text_lower))
    (if (not input)
      (do (utilities.send_plugin_help msg.chat.id msg.message_id bot.config.cmd_pat self) nil)
      (do
        (var (count range) (: input :match "([%d]+)d([%d]+)"))
        (when (not count)
          (set count 1)
          (set range (: input :match "d?([%d]+)$")))
        (if (not range)
          (do (utilities.send_message msg.chat.id self.doc true msg.message_id :html) nil)
          (let [count (tonumber count)
                range (tonumber range)]
            (if (< range 2)
                (do (utilities.send_reply msg "The minimum range is 2.") nil)
                (or (> range 1000) (> count 1000))
                (do (utilities.send_reply msg "The maximum range and count are 1000.") nil)
                ; else
                (let [output (f-str "*{count}d{range}*\n`")]
                  (var output output)
                  (for [a b c]
                    (set output (f-str "{output}{}\t" (math.random range))))
                  (set output (f-str "{output}`"))
                  (utilities.send_message msg.chat.id output true msg.message_id true)
                  nil)))))))
}
