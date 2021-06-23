#!/bin/sh

set -o errexit
set -o nounset

VENDORPULL_SOURCE="$PWD"

set +e
"$VENDORPULL_SOURCE/vendorpull"
EXIT_CODE="$?"
set -e

if [ "$EXIT_CODE" = "0" ]
then
  echo "The help command should not exit successfully"
  exit 1
fi

set +e
"$VENDORPULL_SOURCE/vendorpull" help
EXIT_CODE="$?"
set -e

if [ "$EXIT_CODE" = "0" ]
then
  echo "The help command should not exit successfully"
  exit 1
fi

echo "PASS"
