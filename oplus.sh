#!/data/data/com.termux/files/usr/bin/bash

NAME="OTA FindeR"
AUTHOR="SeRViP"

clear
echo "==============  ${NAME} by ${AUTHOR} =============="

echo " "
echo " "
echo "   ███████╗ ███████╗ ██████╗  ██╗ ██╗ ██╗ ██████╗"
echo "   ██╔════╝ ██╔════╝ ██╔══██╗ ██║ ██║ ██║ ██╔══██╗"
echo "   ███████╗ █████╗   ██████╔╝ ██║ ██║ ██║ ██████╔╝"
echo "   ╚════██║ ██╔══╝   ██╔══██╗ ██╗ ██╝ ██║ ██╔═══╝"
echo "   ███████║ ███████╗ ██║  ██║  ████╝  ██║ ██║"
echo "   ╚══════╝ ╚══════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═╝"
echo " "

NAME="OTA FindeR"
AUTHOR="SeRViP"

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

OUT="/storage/emulated/0/Download/DownloadeR/ota_common.txt"

mkdir -p "$(dirname "$OUT")"


# 📌 Regions, versions, and servers
declare -A REGIONS=(
    [A1]="NA US 10100001"
    [A4]="APC Global 10100100"
    [A5]="OCA Oce_Cen_Australia 10100101"
    [A6]="MEA Middle_East_Africa 10100110"
    [A7]="ROW Global 10100111"
    [1A]="TW Taiwan 00011010"
    [1B]="IN India 00011011"
    [2C]="SG Singapure 00101100"
    [3C]="VN Vietnam 00111100"
    [3E]="PH Philippines 00111110"
    [33]="ID Indonesia 00110011"
    [37]="RU Russia 00110111"
    [38]="MY Malaysia 00111000"
    [39]="TH Thailand 00111001"
    [44]="EUEX Europe 01000100"
    [51]="TR Turkey 01010001"
    [75]="EG Egypt 01110101"
    [82]="HK Hong_Kong 10000010"
    [83]="SA Saudi_Arabia 10000011"
    [9A]="LATAM Latin_America 10011010"
    [97]="CN China 10010111"
)

declare -A VERSIONS=(
  [A]="Launch version" 
  [C]="First update" 
  [F]="Second update" 
  [H]="Third update"
)
declare -A SERVERS=(
  [97]="-r 1" 
  [44]="-r 0" 
  [51]="-r 0"
)

declare -A MODEL_NAMES
if [[ -f phone_name.txt ]]; then
  while IFS='|' read -r codes name; do
    IFS=',' read -ra variants <<< "$codes"
    for code in "${variants[@]}"; do
      code_trimmed=$(echo "$code" | xargs)
      MODEL_NAMES["$code_trimmed"]="$name"
    done
  done < phone_name.txt
fi

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

fix_old_zip() {
  local url="$1"

  echo "$url" | sed \
    -e 's|gauss-componentotamanual.allawnofs.com|gauss-opexcostmanual-eu.allawnofs.com|'
}

# 📌 Funkcia na spracovanie OTA
run_ota() {
    if [[ -z "$region" || -z "${REGIONS[$region]}" ]]; then
        echo -e "${YELLOW}⚠️  Region not set or invalid.${RESET}"
        region="44"
    fi
    region_data=(${REGIONS[$region]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_id=${region_data[2]}
    server="${SERVERS[$region]:--r 3}"
    ota_model="$device_model"
    for rm in TR RU EEA T2 CN IN ID MY TH ; do 
    ota_model="${ota_model//$rm/}"; 
done

       
    ota_command="realme-ota $server $device_model ${ota_model}_11.${version}.01_0001_100001010000 6 $nv_id"
    echo -e "🔍 I run the command: ${BLUE}$ota_command${RESET}"
    output=$(eval "$ota_command")

    real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
    versionName=$(echo "$output" | grep -o '"versionName": *"[^"]*"' | cut -d '"' -f4)
    os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
    android_version=$(echo "$output" | grep -o '"realAndroidVersion": *"[^"]*"' | cut -d '"' -f4)
    security_os=$(echo "$output" | grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
    ota_f_version=$(echo "$real_ota_version" | grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')
    ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')
    ota_version_full="${ota_model}_11.${ota_f_version}_${region_code}_${ota_date}"

# Získať URL k About this update
    about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')
# Získať VersionTypeId
    version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')

# 🟡 Extrahuj celý obsah poľa "header" z JSON výstupu
header_block=$(echo "$output" | sed -n '/"header"\s*:/,/]/p' | tr -d '\n' | sed -E 's/.*"header"[[:space:]]*:[[:space:]]*([^]+).*/\1/')
# 🔍 Skontroluj obsah poľa na výskyt hodnoty
if echo "$header_block" | grep -q 'forbid_ota_local_update=true'; then
    forbid_status="⛔ Forbidden"
elif echo "$header_block" | grep -q 'forbid_ota_local_update=false'; then
    forbid_status="✅ Allowed"
else
    forbid_status="❓ Unknown"
fi


clean_model=$(echo "$device_model" | sed 's/IN\|RU\|TR\|EEA\|T2//g')

# Device_name    
file="phone_name.txt"
result=$(grep "^$ota_model|" "$file" | head -n 1)
phone_name=${result#*|}

# 📋 Output from Servers
clear
echo -e "\n    📱 ${BLUE}${model_name:-$phone_name}${RESET}  (${device_model})${GREEN}$region_name${RESET}  (code:${YELLOW}$region_code${RESET})" 
echo -e "${RED}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}╠══════${RESET}           ${YELLOW} OUTPUT FROM SERVER${RESET}            ${RED}═══════╣${RESET}"
echo -e "${RED}╠═══════════════════════════════════════════════════════╣${RESET}"
printf "${RED}║${RESET} %-17s ${RED}║${RESET} %-33s ${RED}║${RESET}\n" "NAME" "DATA"
echo -e "${RED}╠═══════════════════════════════════════════════════════╣${RESET}"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-34s${RESET}${RED}║${RESET}\n" "OTA Version:" "$real_ota_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Version Firmware:" "$versionName"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Android Version:" "$android_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "OS Version:" "$os_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Security Patch:" "$security_os"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "OTA Status:" "$version_type_id"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-32s${RESET}   ${RED}║${RESET}\n" "Local install:" "$forbid_status"
echo -e "${RED}╚═══════════════════════════════════════════════════════╝${RESET}"
echo -e


    download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
   modified_link=$(echo "$download_link" | sed 's/componentotamanual/componentotamanual/g')       

fixed_zip=$(fix_old_zip "$download_link")

if [[ "$download_link" == *"downloadCheck"* ]]; then
  resolved_zip=$(resolve_zip "$download_link")
else
  resolved_zip="$fixed_zip"
fi


FINAL_ZIP_URL="$download_link"

if [[ "$download_link" == *"downloadCheck"* ]]; then
    FINAL_ZIP_URL=$(resolve_zip "$download_link")
fi
fixed_zip=$(fix_old_zip "$download_link")

cat > "$OUT" <<EOF
MODEL=$clean_model
REGION=$region_data
OTA=$ota_version_full
VERSION_NAME="$versionName"
ANDROID="$android_version"
OS="$os_version"
PATCH=$security_os
VERSION=$version_type_id
LOCAL_INSTALL=$forbid_status
ABOUT="$about_update_url"
DOWNLOAD="$FINAL_ZIP_URL"
EOF


    echo -e "📥    About this update: "
    echo -e " " 
echo -e "🔗 ${GREEN}$about_update_url${RESET}"
    echo -e " "
    if [[ -n "$modified_link" ]]; then
    echo -e "📥    Download link: " 
    echo -e " "
echo -e "🔗 ${GREEN}$modified_link${RESET}"
    else
        echo -e "❌ Download link not found."
        
   fi
 
if [[ -n "$FINAL_ZIP_URL" ]]; then
echo -e " "
echo -e "📥    Resolved link: "
echo -e " "
echo -e "${GREEN}$resolved_zip${RESET}"
else
  echo "❌ No download link found."
fi
    echo "$ota_version_full" >> "ota_${device_model}.txt"
    echo "$modified_link" >> "ota_${device_model}.txt"
    echo "" >> "ota_${device_model}.txt"

    [[ ! -f ota_links.csv ]] && echo "OTA Version" > ota_links.csv
    grep -qF "$modified_link" ota_links.csv || echo "$ota_version_full,$modified_link" >> ota_links.csv
}

# 📌 Výber prefixu a modelu
clear

echo -e "${GREEN}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║${RESET}       ${GREEN}   $NAME${RESET}   ${RED}by${RESET}    ${BLUE}$AUTHOR${RESET}    ${GREEN}         ║${RESET}"
echo -e "${GREEN}╠════════════════════════════════════════════════╣${RESET}"
echo -e "${GREEN}║${RESET}   ${YELLOW_BG}${BLACK}  Realme   ${RESET}    ${GREEN_BG}${BLACK}   Oppo   ${RESET}     ${RED_BG}${WHITE}  OnePlus   ${RESET} ${GREEN}  ║${RESET}"
echo -e "${GREEN}╠════════════════════════════════════════════════╣${RESET}"
printf "${GREEN}║${RESET} %-5s ${GREEN}║${RESET} %-6s ${GREEN}║${RESET} %-18s ${GREEN}║${RESET} %-8s ${GREEN}║${RESET}\n" "Manif" "R Code" "Region" "NV"
echo -e "${GREEN}╠════════════════════════════════════════════════╣${RESET}"

for key in "${!REGIONS[@]}"; do
    region_data=(${REGIONS[$key]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_images=${region_data[2]}

printf "${GREEN}║${RESET}  ${YELLOW}%-4s${RESET} ${GREEN}║${RESET} %-6s ${GREEN}║${RESET} %-18s ${GREEN}║${RESET} %-8s ${GREEN}║${RESET}\n" "$key" "$region_code" "$region_name" "$nv_images"
done


echo -e "${GREEN}╠════════════════════════════════════════════════╣${RESET}"
echo -e "${GREEN}║  ${RESET}"    "     OTA version :  ${BLUE}A${RESET} ,  ${BLUE}C${RESET} ,  ${BLUE}F${RESET} ,  ${BLUE}H${RESET}"      "${GREEN}        ║${RESET}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${RESET}"
# Zoznam prefixov
echo -e "Choose model:
${YELLOW}1) CPH${RESET}, ${GREEN}2) RMX${RESET}, ${BLUE}3) Custom${RESET}, ${PURPLE}4) Selected${RESET}" 
echo -e " "
read -p "💡 Select an option (1/2/3/4): " choice
if [[ "$choice" == "4" ]]; then
    if [[ ! -f devices.txt ]]; then
        echo -e "${RED}❌ Súbor devices.txt neexistuje.${RESET}"
        exit 1
    fi

clear
    echo -e "\n📱 ${PURPLE}Selected device list :${RESET}"
  echo -e "${GREEN}╔══════════════════════════════════════╗${RESET}"
  printf "${GREEN}║${RESET} %-3s | %-30s ${GREEN}║${RESET}\n" "No."      "        Model" 
    echo -e "${GREEN}╠══════════════════════════════════════╣${RESET}"

    mapfile -t lines < devices.txt
        total=${#lines[@]}
    for i in "${!lines[@]}"; do
        index=$((i + 1))
        IFS='|' read -r model region version <<< "${lines[$i]}"
# Pôvodný model z devices.txt
clean_model=$(echo "$model" | grep -oE '(RMX|CPH|PK[A-Z]|PJ[A-Z]|PG[A-Z]|PL[A-Z]|PH[A-Z]|PM[A-Z])[0-9]{3,4}')

# Device_name    
file="phone_name.txt"
result=$(grep "^$clean_model|" "$file" | head -n 1)
phone_name=${result#*|}

device_name="${phone_name}"

printf "${GREEN}║${RESET} ${BLUE}%-3s${RESET} | ${GREEN}%-30s${RESET} ${GREEN}║${RESET}\n" "$index" "$device_name" 
    done

    
  echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"

  read -p "🔢 Select device number: " selected

if [[ "$selected" == "A" || "$selected" == "a" ]]; then
    echo -e "${PURPLE}▶ Running OTA check for all devices...${RESET}"
    for line in "${lines[@]}"; do
        IFS='|' read -r selected_model selected_region selected_version <<< "$line"
        device_model="$(echo "$selected_model" | xargs)"
        region="$(echo "$selected_region" | xargs)"
        version="$(echo "$selected_version" | xargs)"
        
        run_ota
    done
fi

if ! [[ "$selected" =~ ^[0-9]+$ ]] || (( selected < 1 || selected > total )); then
    echo "❌ Invalid selection."; exit 1
fi

IFS='|' read -r selected_model selected_region selected_version <<< "${lines[$((selected-1))]}"
device_model="$(echo "$selected_model" | xargs)"
region="$(echo "$selected_region" | xargs)"
version="$(echo "$selected_version" | xargs)"

echo -e "✅ Selected device: ${BLUE}$device_model${RESET}, ${YELLOW}$region${RESET}, ${BLUE}$version${RESET}"
else
    if [[ "$choice" == "1" ]]; then
        COLOR=$YELLOW
    elif [[ "$choice" == "2" ]]; then
        COLOR=$GREEN
    elif [[ "$choice" == "3" ]]; then
        COLOR=$BLUE
    else
        COLOR=$RESET
    fi

    echo -e "${COLOR}➡️  You selected option $choice${RESET}"

    case $choice in
        1) prefix="CPH" ;;
        2) prefix="RMX" ;;
        3)
            echo " "
            read -p "🧩 Enter your custom prefix (e.g. XYZ): " prefix
            if [[ -z "$prefix" ]]; then
                echo "❌ Prefix cannot be empty."
                exit 1
            fi
            ;;
        *) echo "❌ Invalid choice."; exit 1 ;;
    esac

    # 🧩 Po zadaní model number
echo " " 
read -p "🔢 Enter model number : " model_number
device_model="${prefix}${model_number}"
echo -e "✅ Selected model: ${COLOR}$device_model${RESET}"

# 🧹 Odstráni regionálny suffix (EEA, IN, TR, RU, T2 atď.)
base_model=$(echo "$device_model" | sed 's/EEA\|IN\|TR\|RU\|T2//g')

# 🔍 Vyhľadanie názvu modelu v models.txt podľa základného modelu
model_name=$(grep -i "^$base_model" phone_name.txt | cut -d'|' -f2 | xargs)

if [[ -n "$model_name" ]]; then
    echo -e "📱 Model name: ${COLOR}${model_name}${RESET}"
else
    echo -e "📱 Model name: ${RED}Unknown model (not found in phone_name.txt)${RESET}"
fi    

# 🔍 Pokus o načítanie regiónu podľa názvu modelu
region=""
region_label=""

# Detekcia podľa suffixu (EEA, IN, TR, RU, CN)
if [[ "$device_model" =~ EEA$ ]]; then
    region="44"; region_label="EEA"
elif [[ "$device_model" =~ IN$ ]]; then
    region="1B"; region_label="IN"
elif [[ "$device_model" =~ TR$ ]]; then
    region="51"; region_label="TR"
elif [[ "$device_model" =~ RU$ ]]; then
    region="37"; region_label="RU"
elif [[ "$device_model" =~ CN$ ]]; then
    region="97"; region_label="CN"
fi

    read -p "📌 Manifest + OTA version (e.g. 33F): " input
    region="${input:0:${#input}-1}"
    version="${input: -1}"
fi
# 🧠 Validácia
if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
    echo -e "❌ Invalid input! Exiting."
    exit 1
fi
            if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
                echo "❌ Invalid input."
                continue
            fi

run_ota

# 🔁 Cyklus pre ďalšie voľby
while true; do
    echo -e " "
    echo -e "\n🔄 1 - Change OTA version"
    echo -e "🔄 2 - Change device model"
    echo -e "🔙 3 - Back in Menu"
    echo -e "🔚 0 - End script"
    echo

    read -p "💡 Select an option (1/2/3/0): " option

    case "$option" in
        1)
            echo
            read -p "🧩 Enter OTA version (A/C/F/H): " version
            version=$(echo "$version" | tr '[:lower:]' '[:upper:]')  # prevod na veľké písmená

            if [[ -z "$version" || ! "$version" =~ ^[ACFH]$ ]]; then
                echo -e "${RED}❌ Invalid OTA version.${RESET}"
                continue
            fi

            echo -e "\n🔍 Searching OTA for ${GREEN}$selected_model${RESET} (version ${YELLOW}$version${RESET}) ..."
            run_ota "$selected_model" "$version"
            ;;
        2)
            echo -e "\n🔁 Restarting to select new device..."
            bash "1.sh"
            exit 0
            ;;
        3)
            echo -e "\n🔙 Back maine menu..."
            bash "$0"
            exit 0
            ;;
        0)
            echo -e "👋 Goodbye."
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option.${RESET}"
            ;;
    esac
done
read -p "Press ENTER to return to menu..."
return 0
