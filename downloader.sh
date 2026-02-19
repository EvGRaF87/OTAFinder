#!/data/data/com.termux/files/usr/bin/bash
clear
echo "========= DownloadeR & Resolver ========"

NAME="DownloadeR"
VERSIONS="v1.0"
AUTHOR="SeRViP"
cleanup() {
    echo
    echo "🔙 Returning to menu..."
}
trap cleanup EXIT INT
# 🎨 Colors 
WHITE="\033[37m"
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


[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  echo "❌ Do not run directly. Use menu."
  exit 1
}

COMMON_FILE="/storage/emulated/0/Download/DownloadeR/ota_common.txt"

if [[ ! -f "$COMMON_FILE" ]]; then
  echo "❌ ota_common.txt not found"
  exit 1
fi

source "$COMMON_FILE"

# === 🧠 CHECK ARIA2 ===
if ! command -v aria2c &>/dev/null; then
  echo -e "${RED}❌ aria2c not installed .${RESET}"
  echo "👉 Run: pkg install aria2 -y"
  exit 1
fi

DOWNLOAD_DIR="/storage/emulated/0/Download/DownloadeR"
mkdir -p "$DOWNLOAD_DIR"

for cmd in aria2c curl python3; do
  command -v "$cmd" >/dev/null || {
    echo -e "${RED}❌ Missing: $cmd${RESET}"

    exit 1
  }
done

# -------- Resolver ----------
clean_url() {
  if [[ "$1" == *"4pda.to/stat/go"* ]]; then
    encoded=$(echo "$1" | sed -n 's/.*[?&]u=\([^&]*\).*/\1/p')
    python3 - <<EOF
import urllib.parse
print(urllib.parse.unquote("$encoded"))
EOF
  else
    echo "$1"
  fi
}

# -------- Download resolver ----------
resolve_zip() {
  curl -s -I --http1.1 \
    -H "User-Agent: Dalvik/2.1.0 (Linux; Android 16)" \
    -H "userId: oplus-ota|16002018" \
    -H "Accept: */*" \
    -H "Accept-Encoding: identity" \
    "$1" \
  | grep -i '^location:' \
  | tail -1 \
  | awk '{print $2}' \
  | tr -d '\r'
}

clear
echo -e "${GREEN}╔═════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║${RESET}         ${YELLOW} $NAME${RESET}  ${YELLOW}$VERSIONS${RESET}           ${GREEN}║${RESET}"

echo -e "${GREEN}║${RESET}    ${RED}         by${RESET}  ${BLUE}$AUTHOR  ${RESET}            ${GREEN}║${RESET}"
echo -e "${GREEN}╠═════════════════════════════════════╣${RESET}"                              
echo -e "${GREEN}║${RESET}${YELLOW_BG}${BLACK}   Realme   ${RESET}${GREEN_BG}${BLACK}    Oppo    ${RESET}${RED_BG}${WHITE}   OnePlus   ${RESET}${GREEN}║${RESET}"
echo -e "${GREEN}╚═════════════════════════════════════╝${RESET}" 


while true; do
  echo
  read -rp "🔗 Enter URL: " INPUT
  [[ -z "$INPUT" ]] && continue

  URL=$(clean_url "$INPUT")
    # === 🧠 RESOLVE ===
  if [[ "$URL" == *"downloadCheck"* ]]; then
    echo -e "${YELLOW}🔄 Resolving OTA link...${RESET}"
    ZIP_URL=$(resolve_zip "$URL")

    if [[ -z "$ZIP_URL" ]]; then
      echo -e "${RED}❌ Failed to resolve ZIP link${RESET}"
      echo "⚠️ Link may be expired or region mismatch"
      continue
    fi

    URL="$ZIP_URL"
    echo -e "${GREEN}✔ ZIP resolved:${RESET}"
    echo "$URL"
  fi

  # === 🔍 QUICK CHECK ===
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL")
  if [[ "$STATUS" != "200" ]]; then
    echo -e "${RED}❌ Link invalid (HTTP $STATUS)${RESET}"
    continue
  fi

  echo " "

  echo -e "${BLUE}📥 Downloading...${RESET}"

  echo "➡️ Saving as: $VERSION_NAME"


TARGET_DIR="/storage/emulated/0/Download/DownloadeR"
TARGET_NAME="${VERSION_NAME}_${REGION}.zip"

  aria2c -c -x16 -s16 \
    --user-agent="Dalvik/2.1.0 (Linux; Android 13)" \
    --referer="https://4pda.to/" \
    -d "$DOWNLOAD_DIR" \
    -o "$TARGET_NAME" \
    "$URL"
    
    FINAL_PATH="$TARGET_DIR/$TARGET_NAME"

  if [[ $? -eq 0 ]]; then
    echo "✅ Done: $FINAL_PATH"
    echo "[$(date)] OK"
  else
    echo -e "${RED}❌ Download failed${RESET}"
  fi

  echo
  echo "1️⃣ Download Other URL"
  echo "0️⃣ Exit"
  read -rp "➡️ " C
  [[ "$C" == "0" ]] && break
done