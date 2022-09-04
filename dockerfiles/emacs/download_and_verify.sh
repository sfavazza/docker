# ==================================================================================================
#
# File        : download_and_verify.sh
#
# Purpose     : Download the desired version of emacs and verify its signature
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# ==================================================================================================

. $(pwd)/../common/common.sh

EMACS_VERSION="28.1"
EMACS_FILENAME="emacs-${EMACS_VERSION}.tar.gz"
echo ${EMACS_FILENAME}

exists_or_download "http://mirror.easyname.at/gnu/emacs/${EMACS_FILENAME}"
exists_or_download "http://mirror.easyname.at/gnu/emacs/${EMACS_FILENAME}.sig"

# get the GNU GPG key-ring to verify the downloaded package
exists_or_download "http://mirror.easyname.at/gnu/gnu-keyring.gpg"
gpg --import support/gnu-keyring.gpg

# verify downloaded file (user verifies the printed message)
gpg --verify support/${EMACS_FILENAME}.sig
