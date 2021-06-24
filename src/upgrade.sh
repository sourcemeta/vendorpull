#!/bin/sh

set -o errexit
PATTERN="$1"
REVISION="$2"
set -o nounset

if [ -z "$PATTERN" ]
then
  echo "Usage: $0 <pattern> [revision]" 1>&2
  exit 1
fi

%include "assert.sh"
%include "vcs/git.sh"
%include "tmpdir.sh"
%include "dependencies.sh"

# Get the root directory of the current git repository
BASE_DIRECTORY="$(git rev-parse --show-toplevel)"
DEPENDENCIES_FILE="$BASE_DIRECTORY/DEPENDENCIES"
vendorpull_assert_file "$DEPENDENCIES_FILE"

DEFINITION="$(vendorpull_dependencies_safe_find "$DEPENDENCIES_FILE" "$PATTERN")"

NAME="$(vendorpull_dependencies_name "$DEFINITION")"
REPOSITORY="$(vendorpull_dependencies_repository "$DEFINITION")"
CURRENT_REVISION="$(vendorpull_dependencies_revision "$DEFINITION")"

if [ -n "$REVISION" ] && [ "$REVISION" != "HEAD" ]
then
  if [ "$CURRENT_REVISION" = "$REVISION" ]
  then
    echo "Dependency $NAME is up to date"
    exit 0
  fi

  NEW_REVISION="$REVISION"
else
  echo "Cloning $REPOSITORY..."
  vendorpull_clone_git "$REPOSITORY" "$TEMPORARY_DIRECTORY" HEAD
  NEW_REVISION="$(git -C "$TEMPORARY_DIRECTORY" rev-parse HEAD)"
fi

echo "Upgrading $NAME to $NEW_REVISION"
vendorpull_dependency_set "$DEPENDENCIES_FILE" "$NAME" "$REPOSITORY" "$NEW_REVISION"
