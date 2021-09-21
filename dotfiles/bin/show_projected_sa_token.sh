#!/bin/bash

box_out ()
{
  local s="$*";
  color_border=1;
  color_text=2;
  tput setaf $color_border;
  echo "##${s//?/\#}##
# $(tput setaf $color_text)$s$(tput setaf $color_border) #
##${s//?/\#}##";
  tput sgr 0
}



for cluster in orc-opsplayground prc-devplayground prc-production prc-build; do
  box_out $cluster;
  kubectx $cluster >/dev/null;
  kubectl get pods -o json -A |jq \
    '.items[] | select(.spec.volumes) | select( .spec.volumes[].projected.sources[0].serviceAccountToken) | [.metadata.namespace, .metadata.name] | join("/")'
done
