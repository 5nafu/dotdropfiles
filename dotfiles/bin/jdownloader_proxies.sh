#!/bin/sh
tmux new-session  \;\
  new-window "ssh -D1080 root@srv.peppy.berlin" \;\
  split-window -h \;\
  send-keys "ssh -D1081 snafu@monitor.tvollmer.de" C-m \;\
  split-window -v \;\
  send-keys "ssh -D1082 root@128.140.123.76" C-m \;\
  select-pane -t0 \;\
  split-window -v \;\
  send-keys "ssh -D1083 root@wg.peppy.berlin" C-m \;\


