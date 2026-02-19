#!/data/data/com.termux/files/usr/bin/bash

# ====== BASIC SETUP ======
clear
set +e

NAME="OTA Tool"
VERSION="1.5"
AUTHOR="SeRViP"

BASE_DIR="$HOME/OTA"
SCRIPT_DIR="$BASE_DIR"

# ====== COLORS ======
WHITE="\033[37m"
CYAN="\033[36m"
PURPLE="\033[35m" 
YELLOW="\033[33m"
BLUE="\033[34m"
RED="\033[31m"
BLACK="\033[30m"
WHITE="\033[37m"
GREEN="\033[32m"
YELLOW_BG="\033[43m"
GREEN_BG="\033[42m"
RED_BG="\033[41m"
RESET="\033[0m"

while true; do
  clear

  echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}║${RESET}            ${CYAN}${NAME}${RESET} ${YELLOW}v${VERSION}${RESET}      ${GREEN}     ║${RESET}"
  echo -e "${GREEN}╠════════════════════════════════════╣${RESET}"
  echo -e "${GREEN}║${RESET} ${YELLOW_BG}${BLACK}  realme   ${RESET} ${GREEN_BG}${BLACK}   oppo   ${RESET} ${RED_BG}${WHITE}  OnePlus  ${RESET} ${GREEN}║${RESET}"
  echo -e "${GREEN}╠════════════════════════════════════╣${RESET}"
  echo -e "${GREEN}║${RESET} 1) OTA FindeR                      ${GREEN}║${RESET}"
  echo -e "${GREEN}║${RESET} 2) Share OTA links                 ${GREEN}║${RESET}"
  echo -e "${GREEN}║${RESET} 3) OTA DownloadeR & ResolveR ${GREEN}      ║${RESET}"
  echo -e "${GREEN}║${RESET} 4) EDL FindeR for Realme           ${GREEN}║${RESET}"
  echo -e "${GREEN}║${RESET} 5) ARB CheckeR                     ${GREEN}║${RESET}"
  echo -e "${GREEN}║${RESET} 0) Exit                            ${GREEN}║${RESET}"
  echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"

  echo
  read -p "Select: " choice

  case "$choice" in
    1)
      clear
      source "$SCRIPT_DIR/oplus.sh"
      echo
      read -p "Press ENTER to return to menu..."
      ;;
    2)
      clear
      source "$SCRIPT_DIR/sharelink.sh"
      echo
      read -p "Press ENTER to return to menu..."
      ;;
    3)
      clear
      source "$SCRIPT_DIR/downloader.sh"
      echo
      read -p "Press ENTER to return to menu..."
      ;;
    4)
      clear
      python "$SCRIPT_DIR/edl_finder.py"
      echo
      read -p "Press ENTER to return to menu..."
;;
    5)
      clear
      source "$SCRIPT_DIR/check_arb.sh"
      echo
      read -p "Press ENTER to return to menu..."
;;
   0)
      clear
      echo "Bye 👋"
      exit 0
      ;;
    *)
      echo "❌ Invalid option"
      sleep 1
      ;;
  esac
done