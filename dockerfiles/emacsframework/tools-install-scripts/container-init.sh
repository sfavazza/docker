#!/usr/bin/env bash

# help:
#
# --no-tools: prevent ~/.local tools installation
# --no-emacs: prevent the Emacs server from starting

_script_parent_dir=$(dirname ${BASH_SOURCE[0]})

# default switch
no_tools=""
no_emacs=""

# parse arguments
for arg in "$@"; do
    case "$arg" in
        --no-tools)
            no_tools="1"
            ;;
        --no-emacs)
            no_emacs="1"
            ;;
        *)
            echo "init:: unknown input arg '$arg', skipping..."
            ;;
    esac
done

if [ -z "$no_tools" ]; then
    # RATIONALE: to save .local content on host, the folder shall be bind-mount. This will obscure anything
    # installed in .local at container image build time. The following installation will take some time only on
    # first container up. Then the installers won't try to re-install.
    echo "init:: install tools in ~/.local/ dir..."
    app="$HOME/.local/bin/aider"
    if [ -e "$app" ]; then
        echo "init:: WARNING $app exec found, delete it to re-trigger installation at container startup"
    else
        $_script_parent_dir/aider-install.sh --verbose
    fi
    app="$HOME/.local/.cargo/bin/cargo"
    if [ -e "$app" ]; then
        echo "init:: WARNING $app exec found, delete it to re-trigger installation at container startup"
    else
        sh $_script_parent_dir/rustup-init.sh -y --verbose
    fi
    echo "init:: ...tool installation complete!"
fi

# NOTE: this won't work as it needs sudo... instead don't share the network with host
# # RATIONALE: add current host name to the /etc/hosts to speed up sudo commands complaining about the not found
# # hosts. This happens when instantiating the container w/ network=host. 'sed' cannot be used as cannot change in
# # place. Just add another IP instead.
# hn=$(hostname)
# if [ ! "$(grep $hn /etc/hosts)" ]; then
#     echo "init:: adding hostname '$hn' to /etc/hosts"
#     echo "127.0.1.100 $hn" | sudo tee -a /etc/hosts >/dev/null
# fi

if [ -z "$no_emacs" ]; then
    echo "init:: starting emacs server"
    emacs --fg-daemon=mars
else
    echo "init:: start shell"
    bash
fi
