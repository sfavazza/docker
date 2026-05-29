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
    $_script_parent_dir/aider-install.sh --verbose
    echo "init:: ...tool installation complete!"
fi

if [ -z "$no_emacs" ]; then
    echo "init:: starting emacs server"
    emacs --fg-daemon=mars
else
    echo "init:: start shell"
    bash
fi
