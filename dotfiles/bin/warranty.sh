#!/bin/bash

query="SELECT
  dev.device_pk,
  dev.name,
  dev.serial_no,
  typ.value as Typ,
  MAX(po_item.end_date) as warranty
FROM view_device_v1 dev
  JOIN view_purchaselineitems_to_devices_v1 po_dev_map ON dev.device_pk = po_dev_map.device_fk
  JOIN view_purchaselineitem_v1 po_item ON po_dev_map.purchaselineitem_fk = po_item.purchaselineitem_pk
  JOIN view_device_custom_fields_v1 typ on dev.device_pk = typ.device_fk and key='Typ'
WHERE dev.in_service=true
GROUP BY dev.device_pk, dev.name, dev.serial_no, Typ"

http -f -a $USER:`bw get password "confluence.eu.idealo.com"` \
    'https://dcim.idealo.io/services/data/v1.0/query/' \
    output_type=json \
    query="$query" | \
    jq '.[]| select(.warranty <= "2020-09-27")'

