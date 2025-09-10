#!/usr/bin/env bash
set -euo pipefail

##############################################################################
#
# spring-initializr.nvim — repo sanity checks
#
##############################################################################
die() {
  echo >&2 "$*"
  exit 1
}

##############################################################################
#
# Utils must end with _utils.lua
#
##############################################################################
check_utils_naming() {
    if find lua/spring-initializr/utils -type f -name "*.lua" ! -name "*_utils.lua" | grep -q .; then
    die "Naming error: All files in utils/ must end with _utils.lua"
  fi
}


##############################################################################
#
# Highlight code should live under styles/
#
##############################################################################
check_highlight_layout() {
  if git ls-files '*.lua' | grep -E -q 'utils/.*/?highligh?ts|utils/highligh?ts\.lua'; then
    die "Layout error: highlight(s) belong in styles/, not utils/"
  fi
}

main() {
  check_utils_naming
  check_highlight_layout
}

main "$@"

