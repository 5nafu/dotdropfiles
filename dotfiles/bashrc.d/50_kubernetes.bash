if [[ -d ~/git/kubectx ]]; then
    # Add kubectx files to PATH
    export PATH=$PATH:~/git/kubectx
    # Source bash completion for kubectx
    source ~/git/kubectx/completion/kubectx.bash
    source ~/git/kubectx/completion/kubens.bash
    source <(kubectl completion bash)
    alias k=kubectl
    alias kx=kubectx
    alias kn=kubens
    complete -F __start_kubectl k
    complete -F _kube_contexts  kx
    complete -F _kube_namespaces kn
fi

if [[ -d $KREW_ROOT ]] || [[ -d $HOME/.krew ]]; then
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.local/bin/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/.local/bin/google-cloud-sdk/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/.local/bin/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/.local/bin/google-cloud-sdk/completion.bash.inc"; fi

