(local anise (require :anise))
; For details on configuration values, see README.md#configuration.
{

  ; Your authorization token from the botfather. (string, put quotes)
  :bot_api_key (os.getenv "OTOUTO_BOT_API_KEY")
  ; Your Telegram ID (number).
  :admin (math.floor (os.getenv "OTOUTO_ADMIN_ID"))
  ; Two-letter language code.
  ; Fetches it from the system if available, or defaults to English.
  :lang (let [lang (os.getenv "LANG")]
          (or (and lang (: lang :sub 1 2)) "en"))
  ; The channel, group, or user to send error reports to.
  ; If this is not set, errors will be printed to the console.
  :log_chat (let [log_chat (os.getenv "OTOUTO_LOG_ID")] (or log_chat nil))
  ; The symbol that starts a command. Usually noted as "/" in documentation.
  :cmd_pat "/"
  ; The filename of the database. If left nil, defaults to $username.db.
  :database_name nil
  ; The block of text returned by /start and /about..
  :about_text
"I am otouto, the plugin-wielding, multipurpose Telegram bot.\
\
Send /help to get started."

  :paged_lists {
    :page_length 8
    :list_duration 900
    :private_lists false
  }

  ; some dumb stuff
  :user_lists {
    ; Lists are sorted alphabetically. Set to true to sort backward.
    :reverse_sort false
  }

  ; Generic error messages.
  :errors {
    :generic "An unexpected error occurred."
    :connection "Connection error."
    :results "No results found."
    :argument "Invalid argument."
    :syntax "Invalid syntax."
    :specify_targets "Specify a target or targets by reply, username, or ID."
    :specify_target "Specify a target by reply, username, or ID."
  }

  :administration {
    ; Conversation, group, or channel for kick/ban notifications.
    ; Defaults to config.log_chat if left empty.
    :log_chat nil
    ; link or username
    :log_chat_username nil
    ; First strike warnings will be deleted after this, in seconds.
    :warning_expiration 30
    ; Default flag settings.
    :flags {
      :antibot true
      :antilink true
    }
  }

  :reactions {
    :shrug "¯\\_(ツ)_/¯"
    :lenny "( ͡° ͜ʖ ͡°)"
    :flip "(╯°□°）╯︵ ┻━┻"
    :look "ಠ_ಠ"
    :shots "SHOTS FIRED"
    :facepalm "(－‸ლ)"
  }

  ; To enable a plugin, add its name to the list.
  :plugins (let
      [
        core-critical [
          :core.control
          :core.luarun
          :core.user_info
          :core.group_whitelist
          :core.group_info
        ]
        admin-critical [
          :admin.flags
          :admin.banremover
          :admin.autopromoter
        ]
        admin-filters [
          :admin.antibot
          :admin.antilink
          :admin.antisquigpp
          :admin.antisquig
          :admin.delete_left_messages
          :admin.filterer
          :admin.filesonly
          :admin.nostickers
        ]
        core [
          :core.end_forwards
          :core.user_blacklist
          :core.about
          :core.delete_messages
          :core.disable_plugins
          :core.help
          :core.paged_lists
          :core.ping
          :core.user_lists
        ]
        admin [
          :admin.addadmin
          :admin.addgroup
          :admin.addmod
          :admin.antihammer_whitelist
          :admin.ban
          :admin.deadmin
          :admin.demod
          :admin.filter
          :admin.fixperms
          :admin.getdescription
          :admin.getlink
          :admin.hammer
          :admin.kick
          :admin.kickme
          :admin.listadmins
          :admin.listflags
          :admin.listgroups
          :admin.listmods
          :admin.listrules
          :admin.mute
          :admin.regenlink
          :admin.removegroup
          :admin.setdescription
          :admin.setgovernor
          :admin.setrules
          :admin.tempban
          :admin.unhammer
          :admin.unrestrict
        ]
        user [
          :user.cats
          :user.dice
          :user.echo
          :user.maybe
          :user.reminders
          :user.slap
          :user.user_lookup
          :user.whoami
          :user.xkcd
          :user.reactions
        ]
      ]

    (anise.concat
      core-critical
      admin-critical
      admin-filters
      core
      admin
      user
    ))

}
