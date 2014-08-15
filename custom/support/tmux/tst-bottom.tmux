#!/usr/bin/tmux source-file

new-session -d -s tst-bottom
split-window -d -t 0 -v
split-window -d -t 0 -h

send-keys -t 0 'tst-diag-inst-usb' enter

send-keys -t 1 'tst-diag-tt-status-core' enter

send-keys -t 2 'tst-tail' enter

select-pane -t 0

attach
