# ==================================================================================================
#
# File        : download_sources.sh
#
# Purpose     : Download the support executable for this docker image
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# --------------------------------------------------------------------------------------------------
#
# Description :
# This user can either execute this script in full or simply manually executing the line of interest to get the
# missing source.
#
# ==================================================================================================

. $(pwd)/../common/common.sh

# download the modelsim executable
modelsim_install_script="ModelSimSetup-20.1.1.720-linux.run"

if test -f "$(pwd)/support/$modelsim_install_script"
then
    echo "$modelsim_install_script install script has been already downloaded. Skipping..."
else
    $url_download https://download.altera.com/akdlm/software/acdsinst/20.1std.1/720/ib_installers/
fi
