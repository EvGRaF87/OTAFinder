#!/data/data/com.termux/files/usr/bin/bash
  
# 🎨 Colors
BLUE="\033[34m"
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

echo ""
printf "${RED}╔═════════════════════════════════════════╗${RESET}"
printf "\n${RED}╠══════${RESET}   ${GREEN}===== ARB CheckeR =====${RESET}   ${RED}══════╣${RESET}"
printf "\n${RED}╚═════════════════════════════════════════╝${RESET}"

echo ""
echo ""
  echo
  read -rp "🔗 Enter Image path: " INPUT
  [[ -z "$INPUT" ]] && continue

  Path="$INPUT" 

sleep 1 
echo ""
echo ""
printf "  📋 ${GREEN}Reading ARB Metadata . . .${RESET}"
echo ""
sleep 2
echo ""
printf "  ⌛ ${GREEN}[arbscan] Analyzing:${RESET} $Path"
echo ""
sleep 2
VERSION=$(arbscan "$Path" | grep Version)
ARB=$(arbscan "$Path" | grep ARB)
echo ""
echo ""
echo -e "\n  📦 ${BLUE}OEM Metadata:${RESET}"
printf " ___________________"
echo -e "\n"
echo -e "${VERSION}"
echo -e "${ARB}"
printf " ___________________"
echo ""
echo ""
echo " Done"