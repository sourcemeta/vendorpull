#!/bin/sh

set -o errexit
set -o nounset

INSTALLATION_DIRECTORY="$PWD"
DEPENDENCIES_FILE="$INSTALLATION_DIRECTORY/DEPENDENCIES"
VENDOR_DIRECTORY="$INSTALLATION_DIRECTORY/vendor"
VENDORPULL_DIRECTORY="$VENDOR_DIRECTORY/vendorpull"
VENDORPULL_REPOSITORY="https://github.com/jviotti/vendorpull"

if ! command -v git > /dev/null
then
  echo "You must install git in order to install this tool" 1>&2
  exit 1
fi

mkdir -p "$VENDOR_DIRECTORY"
if [ -d "$VENDORPULL_DIRECTORY" ]
then
  echo "It seems that vendorpull has already been installed at:" 1>&2
  echo "  $VENDORPULL_DIRECTORY" 1>&2
  echo "If this is an error, remove this directory and try again" 1>&2
  exit 1
fi

if [ -f "$DEPENDENCIES_FILE" ]
then
  echo "It seems that there is an existing dependencies manifest at:" 1>&2
  echo "  $DEPENDENCIES_FILE" 1>&2
  echo "If this is an error, remove this file and try again" 1>&2
  exit 1
fi

TEMPORARY_DIRECTORY="$(mktemp -d -t vendorpull-bootstrap-XXXXX)"
temporary_directory_clean() {
  rm -rf "$TEMPORARY_DIRECTORY"
}

# shellcheck disable=SC2039
trap temporary_directory_clean ERR

git clone "$VENDORPULL_REPOSITORY" "$TEMPORARY_DIRECTORY"
cd "$TEMPORARY_DIRECTORY"
HASH="$(git rev-parse HEAD)"
echo "vendorpull $VENDORPULL_REPOSITORY $HASH" > "$DEPENDENCIES_FILE"

cd "$INSTALLATION_DIRECTORY"
"$TEMPORARY_DIRECTORY/update"

echo "Done!"
