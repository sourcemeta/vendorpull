#!/bin/sh

set -o errexit
COMMAND="$1"
set -o nounset

if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "" ]
then
  echo "Usage: $0 <command> [args...]" 1>&2
  echo "" 1>&2
  echo "Commands:" 1>&2
  echo "    pull            Fetch all dependencies defined in DEPENDENCIES" 1>&2
  echo "    pull <pattern>  Fetch the first dependency that matches <pattern>" 1>&2
  exit 1
fi

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

  GIT_REPOSITORY_DIRECTORY="$TEMPORARY_DIRECTORY/$NAME"
  vendorpull_clone_git "$REPOSITORY" "$GIT_REPOSITORY_DIRECTORY" "$REVISION"
  vendorpull_patch "$GIT_REPOSITORY_DIRECTORY" "$1/patches/$NAME"
  vendorpull_clean_git "$GIT_REPOSITORY_DIRECTORY"
  vendorpull_mask_directory "$GIT_REPOSITORY_DIRECTORY" "$1/vendor/$NAME.mask"

  # Atomically move the new dependency into the vendor directory
  OUTPUT_DIRECTORY="$1/vendor/$NAME"
  rm -rf "$OUTPUT_DIRECTORY"
  mkdir -p "$(dirname "$OUTPUT_DIRECTORY")"
  mv "$TEMPORARY_DIRECTORY/$NAME" "$OUTPUT_DIRECTORY"
}

vendorpull_assert_command 'git'

BASE_DIRECTORY="$PWD"

if [ "$COMMAND" = "pull" ]
then
  DEPENDENCIES_FILE="$BASE_DIRECTORY/DEPENDENCIES"
  vendorpull_assert_file "$DEPENDENCIES_FILE"

  shift
  if [ $# -gt 0 ]
  then
    DEFINITION="$(grep "^$1" < "$DEPENDENCIES_FILE" | head -n 1)"
    vendorpull_assert_defined "$DEFINITION" "Could not find a dependency named: $1"
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
