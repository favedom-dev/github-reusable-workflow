#!/usr/bin/env bash

init_colors() {
  NOCOLOR='\033[0m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  DARKGRAY='\033[1;30m'
  GREEN='\033[0;32m'
  LIGHTGRAY='\033[0;37m'
  LIGHTRED='\033[1;31m'
  LIGHTGREEN='\033[1;32m'
  LIGHTBLUE='\033[1;34m'
  LIGHTPURPLE='\033[1;35m'
  LIGHTCYAN='\033[1;36m'
  ORANGE='\033[0;33m'
  PURPLE='\033[0;35m'
  RED='\033[0;31m'
  WHITE='\033[1;37m'
  YELLOW='\033[1;33m'

  COLOR_ERROR=${RED}
  COLOR_SUCCESS=${GREEN}
  COLOR_WARN=${ORANGE}
  COLOR_START=${LIGHTGREEN}
  COLOR_DONE=${GREEN}
  COLOR_VALUE=${BLUE}
  COLOR_CMD=${LIGHTCYAN}

}

run_cmd() {
  echo "----------------------------------"
  echo -e "${COLOR_CMD}${_cmd[*]}${NOCOLOR}"
  eval "${_cmd[@]}"
  RC=${?}
  echo "=================================="
  echo ""
}

handle_rc() {
  if [ "${RC}" -ne 0 ]; then
    echo -e "${COLOR_ERROR}ERROR: rc=${RC} ${ERROR_MESSAGE}${NOCOLOR}"
    exit "${RC}"
  fi
}

init_colors