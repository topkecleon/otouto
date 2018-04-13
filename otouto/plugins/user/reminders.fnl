; reminders.fnl
; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities
  otouto.autils)

{
  :init (fn [self bot]
    (set self.command "remind <interval> <text>")
    (set self.triggers (utilities.make_triggers bot []
      [:remind true] [:remindme true] [:reminder true]))
    (set self.doc "Set a reminder. The interval may be a number of minutes, \z
        or a <i>tiem</i> string, eg <code>3d12h30m</code> (see /help tiem). \z
        Reminders support HTML formatting. The text of a replied-to message \z
        can be made a reminder, if a valid interval follows the command. \n\z
        Example: /remind 4h Look at cat pics. \n\z
        Aliases: /remindme, /reminder.")
    (values))

  ; rmdr {
  ;   :user {:id 55994550 :first_name :Drew}
  ;   :chat_id -8675309
  ;   :text "Post a cat pic."
  ;   :date 1523000000}
  :later (fn [_self bot rmdr]
    (var output (f-str "<b>Reminder from {} (UTC):</b>\n{rmdr.text}"
      (os.date "!%F %T" rmdr.date)))
    (utilities.send_message rmdr.chat_id (if (~= rmdr.from.id rmdr.chat_id)
        (.. (utilities.lookup_name bot rmdr.from.id rmdr.from) "\n" output)
        ;else
        output)
      nil nil :html))

  :action (fn [self bot msg] (let [input (utilities.input msg.text)]
    (local output (if input (do
      (var (text interval) (autils.duration_from_reason input))
      (set text (if text text ; text = text or reply.text or nil
        (and msg.reply_to_message (> #msg.reply_to_message.text 0))
          msg.reply_to_message.text
        ;else
        nil))

      (if (not interval) "Please specify a valid interval, as a number of \z
        minutes or a tiem string, eg <code>3d12h30m</code>."
        (not text) "Please specify text for the reminder."
        ;else
        (do (: bot :do_later self.name (+ (os.time) interval) {
            :from msg.from
            :chat_id msg.chat.id
            :text text
            :date msg.date})
          (.. "I will remind you in " (utilities.tiem.print interval) "."))))

      ; else (if not input)
      (utilities.plugin_help bot.config.cmd_pat self)))

    (utilities.send_reply msg output :html)))
}
