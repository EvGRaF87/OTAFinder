#!/data/data/com.termux/files/usr/bin/bash

NAME="Share OTA links"
AUTHOR="SeRViP"

clear
echo "============= ${NAME} by ${AUTHOR} ============="


# 🎨 Colors
YELLOW="\033[33m";
BLUE="\033[34m"
RED="\033[31m"
BLACK="\033[30m"
WHITE="\033[37m"
GREEN="\033[32m"
YELLOW_BG="\033[43m"
GREEN_BG="\033[42m"
RED_BG="\033[41m"
RESET="\033[0m"

# 📌 Regions, version & codes
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
while IFS='|' read -r code name; do
MODEL_NAMES["$code"]="$name"
done < phone_names.txt
# Načítanie názvov modelov
declare -A MODEL_NAMES
[[ -f phone_names.txt ]] && while IFS='|' read -r code name; do
  MODEL_NAMES["$code"]="$name"
done < phone_names.txt

# 🔧 Funkcia na generovanie variánt modelu
generate_model_variants() {
  local base_model="$1"
  local region="$2"
  local variants=()

  case "$region" in
    44) # EEA: iba základný model a EEA
      variants+=("$base_model" "${base_model}EEA")
      ;;
    37) variants+=("$base_model" "${base_model}RU") ;;
    51) variants+=("$base_model" "${base_model}TR") ;;
    1B) variants+=("$base_model" "${base_model}IN") ;;
    33|38|39|3E) variants+=("$base_model" "${base_model}T2") ;;
    *) variants+=("$base_model") ;;
  esac

  echo "${variants[@]}"
}
# 🛠️ Funkci OTA pre model/variant/region
run_ota() {
  local device_model="$1"
  local version="$2"
  local region="$3"

  region_data=(${REGIONS[$region]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_id=${region_data[2]}
  server="${SERVERS[$region]:--r 3}"

  clean_model=$(echo "$device_model" | sed 's/IN\|RU\|TR\|EEA\|T2//g')
  base_model="$clean_model"

  ota_command="realme-ota $server $device_model ${base_model}_11.${version}.01_0001_100001010000 6 $nv_id"

  output=$(eval "$ota_command")
  
  real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
  [[ -z "$real_ota_version" ]] && return

  # Spracovanie údajov
    real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
    real_version_name=$(echo "$output" | grep -o '"versionName": *"[^"]*"' | cut -d '"' -f4)
    os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
    android_version=$(echo "$output" | grep -o '"realAndroidVersion": *"[^"]*"' | cut -d '"' -f4)
    security_os=$(echo "$output" | grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
    ota_f_version=$(echo "$real_ota_version" | grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')
    ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')
    ota_version_full="${device_model}_11.${ota_f_version}_${region_code}_${ota_date}"

grep -qF "$modified_link" ota_links.csv || echo "$ota_version_full,$modified_link" >> ota_links.csv
# About this update
    about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')

# VersionTypeId
    version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')

# 🟡 Extrahuj celý obsah poľa "header" z JSON výstupu
header_block=$(echo "$output" | sed -n '/"header"\s*:/,/]/p' | tr -d '\n' | sed -E 's/.*"header"[[:space:]]*:[[:space:]]*([^]+).*/\1/')
# 🔍 Skontroluj obsah poľa na výskyt hodnoty
if echo "$header_block" | grep -q 'forbid_ota_local_update=true'; then
    forbid_status="❎ Forbidden"
elif echo "$header_block" | grep -q 'forbid_ota_local_update=false'; then
    forbid_status="✅ Allowed"
else
    forbid_status="❓ Unknown"
fi

# Device_name
file="phone_names.txt"
result=$(grep "^$ota_model|" "$file" | head -n 1)
phone_name=${result#*|}

# 📋 Output from Servers
echo -e "\n    📱 ${BLUE}${model_name:-$phone_name}${RESET}  (${device_model})${GREEN}$region_name${RESET}  (code:${YELLOW}$region_code${RESET})" 
echo -e "${RED}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}╠══════${RESET}           ${YELLOW} OUTPUT FROM SERVER${RESET}            ${RED}═══════╣${RESET}"
echo -e "${RED}╠═══════════════════════════════════════════════════════╣${RESET}"
printf "${RED}║${RESET} %-17s ${RED}║${RESET} %-33s ${RED}║${RESET}\n" "NAME" "DATA"
echo -e "${RED}╠═══════════════════════════════════════════════════════╣${RESET}"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-34s${RESET}${RED}║${RESET}\n" "OTA Version:" "$real_ota_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Version Firmware:" "$real_version_name"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Android Version:" "$android_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "OS Version:" "$os_version"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "Security Patch:" "$security_os"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-33s${RESET} ${RED}║${RESET}\n" "OTA Status:" "$version_type_id"
printf "${RED}║${RESET} ${GREEN}%-17s${RESET} ${RED}║${RESET} ${YELLOW}%-32s${RESET}   ${RED}║${RESET}\n" "Local install:" "$forbid_status"
echo -e "${RED}╚═══════════════════════════════════════════════════════╝${RESET}"
echo -e

    echo -e "  📥                About this update: "
    echo " "
    echo -e "  🔗 ${GREEN}$about_update_url${RESET}"
    echo " "

    download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
    modified_link=$(echo "$download_link" | sed 's/componentotamanual/componentotamanual/g')


    case "$server_id" in
        3) server_code="eu" ;;
        2) server_code="in" ;;
        1) server_code="cn" ;;
        0) server_code="sg" ;;
        *) server_code="eu" ;;
    esac

 #   new_label="gauss-opexcostmanual"
    [[ -n "$server_code" ]] && new_label="${new_label}-${server_code}"
    modified_host="${new_label}.${domain_suffix}"
    modified_link="${download_link/$host/$modified_host}"


    if [[ -n "$modified_link" ]]; then
        echo -e "  📥                  Download link: " 
        echo " " 
        echo -e "  🔗 ${GREEN}$modified_link${RESET}"

else
    echo -e "❌ No download link found."
 fi   

    echo "$ota_version_full" >> "ota_${device_model}.txt"
    echo "$modified_link)" >> "ota_${device_model}.txt"
    echo "" >> "ota_${device_model}.txt"

    [[ ! -f ota_links.csv ]] && echo "OTA verzia,Odkaz" > ota_links.csv
    grep -qF "$modified_link" ota_links.csv || echo "$ota_version_full,$modified_link" >> ota_links.csv
}

# 🔁 Vyhľadanie OTA pre všetky regióny
run_ota_all_regions() {
  local model="$1"
  local version="$2"

  for region in "${!REGIONS[@]}"; do
    variants=$(generate_model_variants "$model" "$region")
    for variant in $variants; do
      run_ota "$variant" "$version" "$region"
    done
  done
}

# 📌 Výber prefixu a modelu
clear

echo -e "${GREEN}╔═════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ${RESET}  ${GREEN} ${NAME}${RESET} ${RED}by${RESET} ${BLUE}${AUTHOR}${RESET}    ${GREEN}   ║${RESET}"
echo -e "${GREEN}╠═════════════════════════════════════╣${RESET}"

echo -e "${GREEN}║${RESET} ${YELLOW_BG}${BLACK}  Realme   ${RESET} ${GREEN_BG}${BLACK}   Oppo   ${RESET} ${RED_BG}${WHITE}  OnePlus   ${RESET} ${GREEN}║${RESET}"



# Výpis tabuľky
for key in "${!REGIONS[@]}"; do
    region_data=(${REGIONS[$key]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}


done



echo -e "${GREEN}╠═════════════════════════════════════╣${RESET}"
echo -e "${GREEN}║  ${RESET}" "OTA version :  ${BLUE}A${RESET} ,  ${BLUE}C${RESET} ,  ${BLUE}F${RESET} ,  ${BLUE}H${RESET}"      "${GREEN}  ║${RESET}"
echo -e "${GREEN}╚═════════════════════════════════════╝${RESET}"
  # 📦 Výber prefixu
echo -e "📦 Model: ${YELLOW}1) CPH${RESET},  ${GREEN}2) RMX${RESET},  ${BLUE}3) Custom${RESET}"
echo " "
read -p "💡 Select an option (1/2/3): " choice

case "$choice" in
  1) COLOR=$YELLOW; prefix="CPH" ;;
  2) COLOR=$GREEN; prefix="RMX" ;;
  3)
     echo " "
     read -p "🧩 Enter your custom prefix (e.g. XYZ): " prefix
     [[ -z "$prefix" ]] && { echo "❌ Prefix cannot be empty."; exit 1; }
     ;;
  *) echo "❌ Invalid choice."; exit 1 ;;
esac

# 🔍 Vyhľadávanie podľa názvu zariadenia
echo " "
read -p "🔍 Search model by name:" search_name
if [[ -n "$search_name" ]]; then
  matches=$(grep -i "$search_name" phone_names.txt)
  if [[ -z "$matches" ]]; then
    echo "❌ No matching models found for '$search_name'."
    exit 1
  fi

  echo -e "\n📋 Found models:"
  mapfile -t match_array < <(echo "$matches")

  for i in "${!match_array[@]}"; do
    IFS='|' read -r codes name <<< "${match_array[$i]}"
    echo -e "${YELLOW}$((i+1)).${RESET} 🟢 ${GREEN}${name}${RESET} → ${BLUE}$(echo "$codes" | xargs)${RESET}"
  done

  echo
  echo " "
  read -p "🔢 Select model number (1-${#match_array[@]}): " model_choice

  if ! [[ "$model_choice" =~ ^[0-9]+$ ]] || (( model_choice < 1 || model_choice > ${#match_array[@]} )); then
    echo "❌ Invalid choice."
    exit 1
  fi

  # 📦 Získaj vybraný model
  IFS='|' read -r codes name <<< "${match_array[$((model_choice-1))]}"
  model_name=$(echo "$name" | xargs)
  IFS=',' read -ra model_variants <<< "$(echo "$codes" | xargs)"

  echo -e "\n✅ Selected device: ${GREEN}${model_name}${RESET}"
  echo -e "📦 Variants: ${YELLOW}${model_variants[*]}${RESET}"
else
  read -p "🔢 Enter model number : " model_number
  device_model="${prefix}${model_number}"
  model_name="${MODEL_NAMES[$device_model]}"
  echo -e "✅ Selected model: ${GREEN}${model_name:-Unknown}${RESET}  (${YELLOW}$device_model${RESET})"
  model_variants=("$device_model")
fi

# 🧩 Zadanie OTA verzie
read -p "🧩 Enter OTA version: " version_input
version="${version_input^^}"

# 🚀 Spustenie vyhľadávania pre všetky varianty
for variant in "${model_variants[@]}"; do
  echo " "
  echo -e "\n🔍 Searching OTA for ${YELLOW}$variant${RESET} ..."
  run_ota_all_regions "$variant" "$version"
done

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
            read -p "🧩 Enter OTA version: " version_input
version="${version_input^^}"

# 🚀 Spustenie vyhľadávania pre všetky varianty
for variant in "${model_variants[@]}"; do
  echo " "
  echo -e "\n🔍 Searching OTA for ${YELLOW}$variant${RESET} ..."
  run_ota_all_regions "$variant" "$version"
done
            ;;
        2)
            echo -e "\n🔁 Restarting to select new device..."
            bash "2.sh"
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