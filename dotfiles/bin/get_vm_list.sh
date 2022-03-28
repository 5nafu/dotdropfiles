#!/bin/bash

LOCATION=$1
ONEHOST=$2

declare -A ENDPOINTS=( 
    [DEV]=onectl-dev-01.kvm00.inf00.eu.idealo.com
    [NBG00]=onectl-pro-01.kvm00.inf00.eu.idealo.com
    [NBG03]=onectl-pro-01.kvm00.inf03.eu.idealo.com
    [NBG05]=onectl-pro-01.kvm00.inf05.eu.idealo.com
    [NBG06]=onectl-pro-01.kvm00.inf06.eu.idealo.com
    [NBG07]=onectl-pro-01.kvm00.inf07.eu.idealo.com
    [SIWO]=onectl-pro-02.kvm00.inf00.eu.idealo.com
)

PASSWORD=$(gopass show -o accounts/internal/${ENDPOINTS[$LOCATION]}/oneadmin)

oneoptions="--user oneadmin --password $PASSWORD --endpoint http://${ENDPOINTS[$LOCATION]}:2633 -v"

for id in $(onevm list $oneoptions -f HOST=$ONEHOST -l ID,HOST --csv | tail -n+2 |cut -d',' -f1); do 
    eval $(onevm show $oneoptions $id |grep "ETH0_SEARCH_DOMAIN\|SET_HOSTNAME"|sed 's/,//'); 
    echo "$SET_HOSTNAME.$ETH0_SEARCH_DOMAIN"; 
done