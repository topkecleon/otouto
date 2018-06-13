; user_lists.fnl
; Paged lists of formatted names.

(local utils (require :otouto.utilities))
(local anise (require :extern.anise))

(local load_and_unload (fn [self _ plugins]
  (set self.lists {})
  (set self.cats {:main {} :sudo {} :admin {}})
  (each [_ plugin (pairs plugins)]
    (when plugin.list
      (tset self.lists plugin.list.name plugin.list)
      (table.insert (if
          plugin.list.sudo self.cats.sudo
          (= plugin.list.type :admin) self.cats.admin
          self.cats.main)
        plugin.list.name)))))

{
  :init (fn [self bot]
    (assert (. bot.named_plugins :core.paged_lists)
            (.. self.name " requires core.paged_lists"))

    (when bot.config.user_lists.reverse_sort (set self.gt (fn [a b] (> a b))))

    (set self.triggers (utils.make_triggers bot {} [:lists? true]))
    (set self.command "list <category>")
    (set self.doc "Returns a paged list of users in the specified category."))

  :action (fn [self bot msg group]
    (let [key (utils.get_word msg.text_lower 2) linfo (. self.lists key)]
      (if (not linfo)
            (utils.send_reply msg (: self :listcats bot msg) :html)
          (and (= linfo.type :admin) (or (not group) (not group.data.admin)))
            (utils.send_reply msg "This list is available in administrated groups.")
          (and linfo.sudo (~= msg.from.id bot.config.admin))
            (utils.send_reply msg "You must be the bot owner to see this list.")
          ; else
            (let [arr (anise.sort (utils.list_names bot (. (if
                        (= linfo.type :userdata) bot.database.userdata
                        (= linfo.type :groupdata) bot.database.groupdata
                        (= linfo.type :admin) group.data.admin)
                      linfo.key))
                    self.gt)
                  (success result) (: (. bot.named_plugins :core.paged_lists)
                                      :send bot msg arr linfo.title)]
              (if success
                  (when (~= result.result.chat.id msg.chat.id)
                    (utils.send_reply msg "List sent privately."))
                ; else
                  (utils.send_reply msg (..
                    "Please <a href=\"https://t.me/" bot.info.username
                    "?start=lists\">message me privately</a> first.") :html))))))

  :listcats (fn [self bot msg]
    (.. "<b>Available Lists</b>\n• " (table.concat (anise.pushcat {}
        self.cats.main
        (if (= bot.config.admin msg.from.id) self.cats.sudo)
        (if (. bot.database.groupdata.admin (tostring msg.chat.id)) self.cats.admin))
      "\n• ")))

  :on_plugins_load load_and_unload
  :on_plugins_unload load_and_unload
}
