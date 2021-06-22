#!/bin/sh

set -o errexit
set -o nounset

# We cannot proceed at all if certain dependencies are not satisfied.
echo "Ensuring system dependencies are satisfied..."
if ! command -v git > /dev/null
then
  echo "You must install git in order to install this tool" 1>&2
  exit 1
fi

# By default, we install vendorpull into the directory it was called from.
# TODO: A slightly better approach is to find the root of the git repo
# we are executing the script on, and use that instead.
INSTALLATION_DIRECTORY="$PWD"

DEPENDENCIES_FILE="$INSTALLATION_DIRECTORY/DEPENDENCIES"

# The repository to install from.
# TODO: We should find a way to make this resistant to repository renames, etc.
VENDORPULL_REPOSITORY="https://github.com/jviotti/vendorpull"

# TODO: If this is the case, then we should do an upgrade instead, once
# we support an "upgrade" command on the main vendorpull script
if [ -f "$DEPENDENCIES_FILE" ]
then
  echo "It seems that there is an existing dependencies manifest at:" 1>&2
  echo "  $DEPENDENCIES_FILE" 1>&2
  echo "If this is an error, remove this file and try again" 1>&2
  exit 1
fi

# Setup a temporary directory
TEMPORARY_DIRECTORY="$(mktemp -d -t vendorpull-bootstrap-XXXXX)"
echo "Setting up temporary directory at $TEMPORARY_DIRECTORY..."
temporary_directory_clean() {
  rm -rf "$TEMPORARY_DIRECTORY"
}
trap temporary_directory_clean EXIT

# Clone the latest available version of vendorpull to perform
# the initial dependencies installation
echo "Cloning vendorpull..."
git clone "$VENDORPULL_REPOSITORY" "$TEMPORARY_DIRECTORY"

if [ -n "$VENDORPULL_REVISION" ]
then
  # We use this for testing purposes, as otherwise we cannot
  # send a pull-request and have the changes to the program
  # be taken into account by the bootstrap script.
  echo "Using input revision..."
  HASH="$VENDORPULL_REVISION"
else
  HASH="$(git -C "$TEMPORARY_DIRECTORY" rev-parse HEAD)"
fi

# Make sure we use the same vendorpull version that we are about
# to install in order to not cause unpredictable results.
git -C "$TEMPORARY_DIRECTORY" checkout "$HASH"

# TODO: We should perform an upgrade here if vendorpull already exists
# in the dependencies file
echo "Creating DEPENDENCIES files..."
echo "vendorpull $VENDORPULL_REPOSITORY $HASH" > "$DEPENDENCIES_FILE"

# After vendorpull has been declared in the repo, run a full update
echo "Running vendorpull..."
cd "$INSTALLATION_DIRECTORY"
"$TEMPORARY_DIRECTORY/update" pull

echo "Done!"
