#!/bin/sh

set -o errexit
COMMAND="$1"
ARGUMENT="$2"
set -o nounset

%include "assert.sh"
%include "vcs/git.sh"
%include "masker.sh"
%include "patcher.sh"
%include "tmpdir.sh"

# @params [string] Base directory
# @params [string] Dependency definition
vendorpull_command_pull() {
  NAME="$(echo "$2" | cut -d ' ' -f 1)"
  REPOSITORY="$(echo "$2" | cut -d ' ' -f 2)"
  REVISION="$(echo "$2" | cut -d ' ' -f 3)"

  echo "Updating $NAME..."

  vendorpull_assert_defined "$NAME" "Missing dependency name"
  vendorpull_assert_defined "$REPOSITORY" "($NAME) Missing repository URL"
  vendorpull_assert_defined "$REVISION" "($NAME) Missing git revision"

  # If the dependency name contains slashes, then we take it to be
  # a full relative path from the base directory
  if echo "$NAME" | grep -q '/'
  then
    OUTPUT_DIRECTORY="$1/$NAME"
  else
    OUTPUT_DIRECTORY="$1/vendor/$NAME"
  fi

  GIT_REPOSITORY_DIRECTORY="$TEMPORARY_DIRECTORY/$NAME"
  vendorpull_clone_git "$REPOSITORY" "$GIT_REPOSITORY_DIRECTORY" "$REVISION"
  vendorpull_patch "$GIT_REPOSITORY_DIRECTORY" "$1/patches/$NAME"
  vendorpull_clean_git "$GIT_REPOSITORY_DIRECTORY"
  vendorpull_mask_directory "$GIT_REPOSITORY_DIRECTORY" "$1/vendor/$NAME.mask"

  # Atomically move the new dependency into the vendor directory
  rm -rf "$OUTPUT_DIRECTORY"
  mkdir -p "$(dirname "$OUTPUT_DIRECTORY")"
  mv "$TEMPORARY_DIRECTORY/$NAME" "$OUTPUT_DIRECTORY"
}

vendorpull_assert_command 'git'

BASE_DIRECTORY="$PWD"
DEPENDENCIES_FILE="$BASE_DIRECTORY/DEPENDENCIES"
vendorpull_assert_file "$DEPENDENCIES_FILE"

# TODO: Add a help command

if [ "$COMMAND" = "pull" ]
then
  if [ -n "$ARGUMENT" ]
  then
    DEFINITION="$(grep "^$ARGUMENT" < "$DEPENDENCIES_FILE" | head -n 1)"
    vendorpull_assert_defined "$DEFINITION" "Could not find a dependency named: $ARGUMENT"
    vendorpull_command_pull "$BASE_DIRECTORY" "$DEFINITION"
  else
    echo "Reading DEPENDENCIES files..."
    while read -r dependency
    do
      vendorpull_command_pull "$BASE_DIRECTORY" "$dependency"
    done < "$DEPENDENCIES_FILE"
    temporary_directory_clean
  fi
else
  vendorpull_fail "Unknown command: $COMMAND"
fi
