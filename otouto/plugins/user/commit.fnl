;; commit.fnl
;; Returns a commit message from whatthecommit.com.

;; Copyright 2019 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local http (require :socket.http))
(local utilities (require :otouto.utilities))
(local bindings (require :extern.bindings))

{
  :init (fn [self bot]
    (set self.triggers (utilities.make_triggers bot [] :commit))
    (set self.command :commit)
    (set self.doc "Returns a commit message from whatthecommit.com.")
    (set self.url "http://whatthecommit.com/index.txt")
    (set self.alt "add more cowbell")
  )

  :action (fn [self _ msg]
    (bindings.sendMessage {
      :chat_id msg.chat.id
      :text (.. "<code>" (or (http.request self.url) self.alt) "</code>")
      :parse_mode :html
    })
  )
}