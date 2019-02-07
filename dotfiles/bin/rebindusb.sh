#!/bin/bash
for i in /sys/bus/pci/drivers/[uoex]hci_hcd/*:*; do
  echo "${i##*/}" |sudo tee "${i%/*}/unbind"
  echo "${i##*/}" |sudo tee "${i%/*}/bind"
done

