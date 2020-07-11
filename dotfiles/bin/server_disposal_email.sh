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
echo "Querying for QSC:"
qscoutput=$(curl -su $USER -d output_type=csv -d header=no -d delimiter=" " -d query="SELECT
  '*',
  qsc.value as qsc,
  '/',
  dev.asset_no,
  'in',
  rack.name,
  room.name,
  'HE',
  dev.start_at
FROM view_device_v1 dev
  JOIN view_device_custom_fields_v1 qsc on dev.device_pk = qsc.device_fk and key='QSC'
  JOIN view_rack_v1 rack on dev.rack_fk = rack.rack_pk
  JOIN view_room_v1 room on rack.room_fk = room.room_pk
  WHERE dev.asset_no in ($hostlist)" 'https://dcim.idealo.io/services/data/v1.0/query/')

echo "Querying for procurement:"
procurementoutput=$(curl -su $USER -d output_type=csv -d header=no -d delimiter=" " -d query="SELECT
  '*', 'QSC#',
  custom.\"QSC\",
  '/', 'Asset#',
  dev.asset_no,
  '/', 'AS#',
  custom.\"AS\",
  '/', 'ServiceTag',
  dev.serial_no
FROM view_device_v1 dev
  JOIN view_device_custom_fields_flat_v1 custom on dev.device_pk = custom.device_fk
  WHERE dev.asset_no in ($hostlist)" 'https://dcim.idealo.io/services/data/v1.0/query/')

echo "
----------------------------------------------------
Hallo QSC,

bitte baut folgenden Server und die zugehörigen Festplatten aus und entsorgt
alles:

$qscoutput

Vielen Dank."


echo "
----------------------------------------------------
Hallo ,

ich habe gerade bei QSC die Entsorgung folgenden Servers und seiner Festplatten beauftragt:

$procurementoutput

Vielen Dank."
