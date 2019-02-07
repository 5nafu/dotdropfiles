#!/bin/bash

apiuser="director:Mmksl9F8l6"
curl -k -s -u "$apiuser" -H 'X-HTTP-Method-Override: GET' -X POST https://icinga2-master-pro-01.srv00.inf05.eu.idealo.com:5665/v1/objects/services "$@"
