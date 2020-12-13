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

url_download="wget --append-output=wget.log --verbose --continue"

# download the modelsim executable
$url_download https://download.altera.com/akdlm/software/acdsinst/20.1std.1/720/ib_installers/ModelSimSetup-20.1.1.720-linux.run
