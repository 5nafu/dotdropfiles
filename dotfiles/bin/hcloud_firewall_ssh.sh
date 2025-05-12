#! /bin/bash

usage() {
   cat <<EOF
Usage: $0 -o|-c|-p -n <bitwarden|webserver> -i <IP/range> -T <host> -P <port>
where:
    -o open ssh
    -d close ssh
    -p start proxy session
    -n name of firewall (one of "bitwarden" or "webserver")
    -i IP range (CIDR). Uses current IP as default
    -T target host (only used by proxy session)
    -P target port (only used by proxy session)
EOF
}

OPTSTRING="ocpn:i:T:"

while getopts ${OPTSTRING} opt; do
  case ${opt} in
    o)
      if [[ -z $ACTION ]]; then
        ACTION=add-rule
      else
       echo -e "Only one action allowed\n" 
       usage
       exit 1
      fi
      ;;
    c)
      if [[ -z $ACTION ]]; then
        ACTION=delete-rule
      else
       echo -e "Only one action allowed\n" 
       usage
       exit 1
      fi
      ;;
    p)
      if [[ -z $ACTION ]]; then
        ACTION=proxy
      else
       echo -e "Only one action allowed\n" 
       usage
       exit 1
      fi
      ;;
    n)
      INPUT_FIREWALL_NAME=${OPTARG}
      ;;
    i)
      IP_RANGE=${OPTARG}
      ;;
    T)
      TARGET_HOST=${OPTARG}
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    ?)
      echo -e "Invalid option: -${OPTARG}.\n"
      usage
      exit 1
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$ACTION" ]]; then
  echo -e "Action missing\n"
  usage
  exit 3
fi

if [[ -z "$INPUT_FIREWALL_NAME" ]] ; then
  echo -e "Firewall name unset\n"
  usage
  exit 3
fi

if [[ -z $INPUT_FIREWALL_NAME ]] ; then
  echo -e "Firewall name unset\n"
  usage
  exit 3
fi

case $INPUT_FIREWALL_NAME in
  bitwarden)
    export HCLOUD_TOKEN="7FM2JaLy3IDhMKvMWaQXwEjWRPvv3qaE36pZh0Soy6vb4F2ChOLaTAJ5qaJCzAbz"
    [[ -z "$TARGET_HOST" ]] && TARGET_HOST=bitwarden
    ;;
  webserver)
    export HCLOUD_TOKEN="lmu9oZ6E1N55WOy4XBO6v8MwXVof5MTw5ZiIrD00jNDHpjHcADuK8kfBlxyVTPrk"
    [[ -z "$TARGET_HOST" ]] && TARGET_HOST=srv
    ;;
  *)
    echo "Unknown firewall. Use one of <bitwarden|webserver>"
    exit 4
    ;;
esac

[[ -z "$IP_RANGE" ]] && IP_RANGE="$(wget -O- -q http://ifconfig.me/ip )/32"

if [[ "$ACTION" == "proxy" ]]; then
  [[ -z "$TARGET_HOST" ]] && echo "Target Host not set. Exiting" && exit 128

  hcloud firewall add-rule \
    $INPUT_FIREWALL_NAME \
    --direction in \
    --port 22 \
    --protocol tcp \
    --source-ips $IP_RANGE \
    --description "Doorkeeper Rule - ssh proxy - $IP_RANGE"
  
  ssh $TARGET_HOST

  hcloud firewall delete-rule \
  $INPUT_FIREWALL_NAME \
  --direction in \
  --port 22 \
  --protocol tcp \
  --source-ips $IP_RANGE \
  --description "Doorkeeper Rule - ssh proxy - $IP_RANGE"
else
  hcloud firewall $ACTION \
    $INPUT_FIREWALL_NAME \
    --direction in \
    --port 22 \
    --protocol tcp \
    --source-ips $IP_RANGE \
    --description "Doorkeeper Rule - shell - $IP_RANGE"
fi
