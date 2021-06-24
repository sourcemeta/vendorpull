#!/bin/sh

set -o errexit
REVISION="$VENDORPULL_REVISION"
set -o nounset

%include "assert.sh"
%include "vcs/git.sh"

vendorpull_assert_command 'git'

# Get the root directory of the current git repository
INSTALLATION_DIRECTORY="$(git rev-parse --show-toplevel)"

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

%include "tmpdir.sh"

# Clone the latest available version of vendorpull to perform
# the initial dependencies installation
echo "Cloning vendorpull..."
vendorpull_clone_git "$VENDORPULL_REPOSITORY" "$TEMPORARY_DIRECTORY" HEAD

if [ -n "$REVISION" ]
then
  # We use this for testing purposes, as otherwise we cannot
  # send a pull-request and have the changes to the program
  # be taken into account by the bootstrap script.
  echo "Using input revision $REVISION"
  HASH="$REVISION"
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
echo "Pulling dependencies ..."
cd "$INSTALLATION_DIRECTORY"
"$TEMPORARY_DIRECTORY/pull"

echo "Done!"
