#!/bin/bash

# ==================================================================================================
#
# File        : common.sh
#
# Purpose     : Collection of common definitions for other shell scripts in each Docker folders
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# ==================================================================================================

url_download="wget --append-output=wget.log --verbose --continue --show-progress"

exists_or_download () {
    # Consider the text after the last slash as the name of the file to be (perhaps) downloaded. It checks its
    # existence in the target folder (default to the "support" folder in the folder it is called from) if it
    # does not exists it downloads it. Optionally it is possible to indicate an alternative destination folder
    # (it must be an absolute path).
    #
    # USAGE:
    #     exists_or_download <your_link_to_the_remote_file> [<absolute_destination_path>]

    # define the download destination directory based on the folder from within this function is called
    if [ -z $2 ]
    then
        target_dir=$(pwd)/support
    else
        target_dir=$2
    fi

    # extract the script file name
    IFS=/ read -ra LINK_WORDS_ARRAY <<< $1
    install_script=${LINK_WORDS_ARRAY[-1]}

    if test -f "$target_dir/$install_script"
    then
        echo "$install_script install script has been already downloaded. Skipping..."
    else

        echo "downloading $install_script in $target_dir"
        $url_download --directory-prefix=$target_dir $1

        # make the newly downloaded file executable
        chmod u+x $target_dir/$install_script
    fi
}
