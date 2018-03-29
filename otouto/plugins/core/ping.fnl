;; ping.lua
;; Sends a response, then updates it with the time it took to send.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local socket (require :socket))
(local bindings (require :otouto.bindings))
(local utilities (require :otouto.utilities))
(require-macros :otouto.macros)

{
  :init (fn [self bot]
    (set self.command "ping")
    (set self.doc "Pong!\z
      \nUpdates the message with the time used, in seconds, to send the response.")
    (set self.triggers (utilities.make_triggers bot [] :ping :marco :annyong))
    (values))

  :action (fn [self bot msg]
    (local a (socket.gettime))
    (local answer (if (: msg.text_lower :match :marco)
                      "Polo!"
                      (: msg.text_lower :match :annyong)
                      "Annyong."
                      ; else
                      "Pong!"))
    (local message (utilities.send_reply msg answer))
    (local b (string.format "%.3f" (- (socket.gettime) a)))
    (when message
      (local edit (bindings.editMessageText {
        :chat_id msg.chat.id
        :message_id message.result.message_id
        :text (f-str "{answer}\n`{b}`")
        :parse_mode :Markdown
      })))
    nil)
}
