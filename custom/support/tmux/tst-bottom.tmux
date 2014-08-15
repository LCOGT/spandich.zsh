#!/usr/bin/tmux source-file

new-session -d -s tst-bottom
split-window -d -t 0 -v
split-window -d -t 0 -h

send-keys -t 0 'clear ; tst-diag-inst-usb' enter

send-keys -t 1 'clear ; tst-diag-tt-status-core' enter

send-keys -t 2 'clear ; tst-tail' enter

select-pane -t 0

attach
