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

# remove previous versions by listing all files except the ones featuring the target version
for suffix in "" ".sig"; do
    FILES_RM_LIST="\
$FILES_RM_LIST $(ls support/emacs-*.tar.gz${suffix} \
| awk -F ${EMACS_FILENAME}${suffix} '{print $1}')"
done

rm -f FILES_RM_LIST

exists_or_download "http://mirror.easyname.at/gnu/emacs/${EMACS_FILENAME}"
exists_or_download "http://mirror.easyname.at/gnu/emacs/${EMACS_FILENAME}.sig"

# always remove the gpg-keyring to always get the latest
rm -f support/gnu-keyring.gpg

# get the GNU GPG key-ring to verify the downloaded package
exists_or_download "http://mirror.easyname.at/gnu/gnu-keyring.gpg"
gpg --import support/gnu-keyring.gpg

# verify downloaded file (user verifies the printed message)
gpg --verify support/${EMACS_FILENAME}.sig
