;; end_forwards.fnl
;; This plugin keeps forwarded messages from hitting any plugin after it in the
;; load order. Just put this wherever, close to the top. The only plugins which
;; need to see forwarded messages are usually administration-related.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

{ :triggers [""] :action (fn [_ _ msg] (and (not msg.forward_from) :continue)) }
