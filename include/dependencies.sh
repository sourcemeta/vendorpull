# @params [string] Dependency definition
vendorpull_dependencies_name() {
  RESULT="$(echo "$1" | cut -d ' ' -f 1)"
  vendorpull_assert_defined "$RESULT" "Missing dependency name"
  echo "$RESULT"
}

# @params [string] Dependency definition
vendorpull_dependencies_repository() {
  RESULT="$(echo "$1" | cut -d ' ' -f 2)"
  vendorpull_assert_defined "$RESULT" "Missing dependency url"
  echo "$RESULT"
}

# @params [string] Dependency definition
vendorpull_dependencies_revision() {
  RESULT="$(echo "$1" | cut -d ' ' -f 3)"
  vendorpull_assert_defined "$RESULT" "Missing dependency revision"
  echo "$RESULT"
}

# @params [string] Path to DEPENDENCIES file
# @params [string] Pattern
vendorpull_dependencies_find() {
  if [ ! -f "$1" ]
  then
    echo ""
  fi

  grep "^$2" < "$1" | head -n 1
}

# @params [string] Path to DEPENDENCIES file
# @params [string] Pattern
vendorpull_dependencies_safe_find() {
  DEFINITION="$(vendorpull_dependencies_find "$1" "$2")"
  vendorpull_assert_defined "$DEFINITION" "Could not find a dependency $2 in $1"
  echo "$DEFINITION"
}

# @params [string] Path to DEPENDENCIES file
# @params [string] Dependency name
vendorpull_dependencies_find_exact() {
  if [ ! -f "$1" ]
  then
    echo ""
  fi

  grep "^$2 " < "$1" | head -n 1
}

# @params [string] Path to DEPENDENCIES file
# @params [string] Dependency name
# @params [string] Dependency url
# @params [string] Dependency revision
vendorpull_dependency_set() {
  DEPENDENCY="$(vendorpull_dependencies_find_exact "$1" "$2")"
  if [ -z "$DEPENDENCY" ]
  then
    echo "$2 $3 $4" >> "$1"
  else
    sed -i .bak "s#^$2 .*#$2 $3 $4#" "$1"
    rm "$1.bak"
  fi
}
