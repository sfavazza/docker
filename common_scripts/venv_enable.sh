#!/usr/bin/env bash

# Description: identify the list of virtual environments and propose the user to choose which one to be enabled.

echo ""
echo "WARNING: you must SOURCE this script!"

[ -z "$WORKON_HOME" ] && echo "WORKON_HOME is not defined aborting..." && exit 1

# find a list of virtual environments and ask the user to choose via a value

LIST_VENV=$(ls $WORKON_HOME)

# ask for user choice
echo "Select a virtual environments among the following by its index:"
select venv_to_enable in $LIST_VENV; do
    if [ -z "$venv_to_enable" ]; then
        echo "invalid selection $REPLY"
    else
        echo "selected: $venv_to_enable"
        break
    fi
done

source $WORKON_HOME/$venv_to_enable/bin/activate
