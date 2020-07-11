function reload_kubeconfig() {
    export KUBECONFIG=".kubeconfig:$HOME/.kube/config:$(ls ~/.kube/config.d/*|xargs|sed 's/ /:/g')"
}

if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="reload_kubeconfig"
else
    PROMPT_COMMAND="$PROMPT_COMMAND;reload_kubeconfig"
fi

