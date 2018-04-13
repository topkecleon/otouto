;; delete_messages.fnl
;; Provides a "later" job to delete messages.

(local bindings (require "otouto.bindings"))

{
  :later (fn [_self _bot param]
    (bindings.deleteMessage {
      :chat_id param.chat_id
      :message_id param.message_id}))
}

;;  (: bot :do_later :core.delete_messages when {
;;    :chat_id msg.chat.id
;;    :message_id msg.message_id})
