;; disable_plugins.fnl
;; This plugin manages the list of disabled plugins for a group. Put this
;; anywhere in the plugin ordering.

;; Copyright 2017 bb010g <bb010g@gmail.com>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* anise
          otouto.bindings
          otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "(disable|enable) <plugin>…")
    (set self.doc "Sets whether plugins are enabled or disabled in a group. You must have ban \z
      permissions to use this.\n\n\z
      If no plugins are provided, currently disabled plugins are listed.")
    (set self.triggers (utilities.make_triggers bot [] [:disable true] [:enable true]))
    (values))

  :get_disabled (fn [disabled chat_str create]
    (var chat_disabled (. disabled chat_str))
    (when (= chat_disabled nil)
      (set chat_disabled {})
      (when create (tset disabled chat_str chat_disabled)))
    chat_disabled)

  :blacklist {
    :core.about true
    :core.control true
    :core.delete_messages true
    :core.disable_plugins true
    :core.end_forwards true
    :core.group_info true
    :core.group_whitelist true
    :core.luarun true
    :core.paged_lists true
    :core.user_blacklist true
    :core.user_info true
    :core.user_lists true
  }

  :toggle (fn [self named_plugins chat_disabled enable pnames]
    (let [blacklist self.blacklist
          disabled {}
          enabled {}
          not_found {}
          blacklisted {}]
      (each [_ pname (pairs pnames)]
        (if (not (. named_plugins pname))
            (table.insert not_found pname)
            (. blacklist pname)
            (table.insert blacklisted pname)
            (and enable (. chat_disabled pname))
            (do (tset chat_disabled pname nil)
                (table.insert enabled pname))
            (and (not enable) (not (. chat_disabled pname)))
            (do (tset chat_disabled pname true)
                (table.insert disabled pname))
            ; else
            nil))
      (values disabled enabled not_found blacklisted)))

  :action (fn [self bot msg]
    (local chat_id msg.chat.id)
    (local chat_str (tostring chat_id))
    (local input (utilities.input_from_msg msg))
    (local disabled_plugins bot.database.disabled_plugins)
    (if (not input)
      (let [chat_disabled (self.get_disabled disabled_plugins chat_str false)
            disabled (anise.keys chat_disabled)]
        (if (not (. disabled 1))
          (do (utilities.send_message chat_id "All plugins are enabled.") nil)
          (let [output (.. "<b>Disabled plugins:</b>\n• " (table.concat disabled "\n• "))]
            (utilities.send_message chat_id output true nil :html)
            nil)))
      (let [chat_disabled (self.get_disabled disabled_plugins chat_str true)
            (cm_success chat_member) (bindings.getChatMember {:chat_id chat_id :user_id msg.from.id})
            chat_member (and cm_success chat_member.result)]
        (if
          (not cm_success)
          (do (utilities.send_reply msg "Couldn't fetch permissions.") nil)
          (not (or chat_member.can_restrict_members (= chat_member.status :creator)))
          (do (utilities.send_reply msg "You need ban permissions.") nil)
          ; else
          (let [enable
                  (and-or (: msg.text_lower :match (f-str "^{bot.config.cmd_pat}enable")) true false)
                pnames (anise.split_str input)
                (disabled enabled not_found blacklisted)
                  (: self :toggle bot.named_plugins chat_disabled enable pnames)
                output {}
                sep ", "]
            (when (= (next chat_disabled) nil)
              (tset disabled_plugins chat_str nil))
            (table.insert output
              (if (. blacklisted 1)
                  (.. "<b>Blacklisted:</b> " (table.concat blacklisted sep))
                  (. disabled 1)
                  (.. "<b>Disabled:</b> " (table.concat disabled sep))
                  (. enabled 1)
                  (.. "<b>Enabled:</b> " (table.concat enabled sep))
                  (. not_found 1)
                  (.. "<b>Not found:</b> " (table.concat not_found sep))
                  ; else
                  "Nothing changed."))
            (utilities.send_reply msg (table.concat output "\n") :html)
            nil)))))
}
