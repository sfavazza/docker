# ==============================================================================================================
# Purpose: Download the support libraries to be installed in the docker image
# ==============================================================================================================

. $(pwd)/../common/common.sh

exists_or_download "http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz"
