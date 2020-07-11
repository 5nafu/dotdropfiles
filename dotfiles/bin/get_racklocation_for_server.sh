#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Get server information from dcim and print out email to QSC requesting the disposal of the servers"
    echo "$0 <asset_no> [<asset_no> ...]"
    exit 1
fi

hostlist=""
for host in $@; do
    if [[ -z "$hostlist" ]]; then
        hostlist="'$host'"
    else
        hostlist="$hostlist, '$host'"
    fi
done
PASS=$(bw get password "confluence.eu.idealo.com")
output=$(curl -su $USER:$PASS -d output_type=csv -d header=no -d delimiter=" " -d query="SELECT
  dev.asset_no, dev.name,
  rack.name || ' HE' || dev.start_at as Location
FROM view_device_v1 dev
  JOIN view_rack_v1 rack on dev.rack_fk = rack.rack_pk
  WHERE dev.asset_no in ($hostlist)" 'https://dcim.idealo.io/services/data/v1.0/query/')


echo "$output"
