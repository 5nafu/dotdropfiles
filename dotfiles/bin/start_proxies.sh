#!/bin/bash

# trap 'jobs -p | xargs -r kill ' EXIT
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT


PORT=1080

HOSTS=(
snafu@bitwarden.tvollmer.de
root@65.21.57.252 # centos-2gb-hel1-1
root@65.21.61.139 # ubuntu-2gb-hel1-2
root@mail.tvollmer.de
tobias@pihole.tvollmer.de
snafu@jira.tvollmer.de
snafu@monitor.tvollmer.de
root@116.203.216.110 # Paperless
tobias@65.21.150.54 # traefik
)

for host in ${HOSTS[@]}; do
    echo "*** Starting proxy on port '$PORT' via host '$host' ***"
    ssh -N -D $PORT $host >>/tmp/proxy.log 2>&1 &
    ((PORT++))
    sleep 5
done

echo "#############################"
echo "# Finished starting Proxies #"
echo "#############################"
echo ""
echo "Press <ENTER> to close connections"
read
