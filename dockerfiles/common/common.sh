# ==================================================================================================
#
# File        : common.sh
#
# Purpose     : Collection of common definitions for other shell scripts in each Docker folders
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# ==================================================================================================

url_download="wget --append-output=wget.log --verbose --continue --directory-prefix=$(pwd)/support"

exists_or_download () {
    # Check the existence of the file at the end of the given link to check whether it exists in the "support"
    # folder. If not the given link is give to wget command.
    #
    # USAGE:
    #     exists_or_download <your_link_to_install_script>

    install_script              # TODO: implement the function to be used in the other docker folders

    if test -f "$(pwd)/support/$anaconda_install_script"
    then
        echo "$anaconda_install_script install script has been already downloaded. Skipping..."
    else
        $url_download https://repo.anaconda.com/miniconda/$anaconda_install_script
    fi
}
