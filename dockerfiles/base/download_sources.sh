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

# download miniconda executable
$url_download https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
