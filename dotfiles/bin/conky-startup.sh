echo "Starting conky $(date)" >>/tmp/conky.log
sleep 20s
killall conky
cd "$HOME/.conky/tvollmer"
conky -c "$HOME/.conky/tvollmer/tvollmer_all" &
cd "$HOME/.conky/tvollmer"
conky -c "$HOME/.conky/tvollmer/undertherug_right" &
