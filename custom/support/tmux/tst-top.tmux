#!/usr/bin/tmux source-file

new-session -d -s tst-top

split-window -d -t 0 -v
split-window -d -t 0 -h
split-window -d -t 2 -h

resize-pane -t 0 -D 5

send-keys -t 0 'clear ; sudo tshark -V -R "http.request || http.response" -i p3p1 port 80 and \( host tt or host fw \)' enter

send-keys -t 1 'clear ; sudo trafshow -a 32 -i p3p1 "dst host tt or dst host fw"' enter

send-keys -t 2 "clear ; tst-tail-dbhost-value 'Instrument CCD Heater Power'" enter

send-keys -t 3 'clear ; sudo trafshow -a 32 -i p3p1 "dst host dbhost and ( dst port 80 or dst port 3306 )"' enter

select-pane -t 0

attach
