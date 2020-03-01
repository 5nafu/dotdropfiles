source ~/.kubectx/completion/kubectx.bash
source ~/.kubectx/completion/kubens.bash
source <(kubectl completion bash)
alias k=kubectl
alias kx=kubectx
alias kn=kubens
complete -F __start_kubectl k
complete -F _kube_contexts  kx
complete -F _kube_namespaces kn

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
