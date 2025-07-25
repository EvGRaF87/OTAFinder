#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/oplus.sh"

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="$HOME/OTA"
B_SH_PATH="$OTA_DIR/oplus.sh"
REALME_OTA_BIN="/data/data/com.termux/files/usr/bin/realme-ota"

# Вывод ошибки
handle_error() {
    echo -e "\n${RED}ОШИБКА: $1${RESET}"
    echo -e "${YELLOW}Установка прервана.${RESET}"
    exit 1
}

# --- НАЧАЛО СКРИПТА ---
clear
echo -e "${BLUE}=====================================================${RESET}"
echo -e "${BLUE}==  Автоматический установщик OTAFindeR by SeRViP  ==${RESET}"
echo -e "${BLUE}=====================================================${RESET}"
echo ""
echo -e "${YELLOW}Этот скрипт автоматически скачает и настроит всё необходимое.${RESET}"
read -p "Нажмите [Enter] для начала..."

# --- Шаг 1: Настройка хранилища и обновление пакетов ---
echo -e "\n${GREEN}>>> Шаг 1: Настройка хранилища и обновление системы...${RESET}"
termux-setup-storage
mkdir -p "$OTA_DIR" || handle_error "Не удалось создать папку $OTA_DIR."

DPKG_OPTIONS="-o Dpkg::Options::=--force-confold"
pkg update -y || handle_error "Не удалось обновить списки пакетов."
pkg upgrade -y $DPKG_OPTIONS || handle_error "Не удалось обновить пакеты."
echo -e "${GREEN}Система Termux успешно обновлена.${RESET}"

# --- Шаг 2: Установка зависимостей ---
echo -e "\n${GREEN}>>> Шаг 2: Установка системных пакетов (python, git, tsu)...${RESET}"
pkg install -y $DPKG_OPTIONS python python2 git tsu curl || handle_error "Не удалось установить системные пакеты."
echo -e "${GREEN}Все системные пакеты установлены.${RESET}"

# --- Шаг 3: Установка Python-модулей ---
echo -e "\n${GREEN}>>> Шаг 3: Установка Python-модулей...${RESET}"
pip install --upgrade pip wheel pycryptodome || handle_error "Не удалось установить wheel или pycryptodome."
pip3 install --upgrade requests pycryptodome git+https://github.com/R0rt1z2/realme-ota || handle_error "Не удалось установить realme-ota."

# Права доступа
if [ -f "$REALME_OTA_BIN" ]; then
    echo -e "${BLUE}Назначаем права на исполнение для realme-ota...${RESET}"
    chmod +x "$REALME_OTA_BIN"
else
    echo -e "${YELLOW}ПРЕДУПРЕЖДЕНИЕ: Не найден файл $REALME_OTA_BIN. Возможны проблемы в работе.${RESET}"
fi
echo -e "${GREEN}Python-модули успешно установлены и настроены.${RESET}"

# --- Шаг 4: Загрузка скрипта oplus.sh ---
echo -e "\n${GREEN}>>> Шаг 4: Загрузка скрипта (oplus.sh)...${RESET}"

if [ ! -d "$OTA_DIR" ]; then
  mkdir -p "$OTA_DIR"
  if [ $? -eq 0 ]; then
    echo "Создана '$OTA_DIR' папка."
  else
    echo "Ошибка при создании папки '$OTA_DIR'."
    exit 1
  fi
else
  echo "Папка '$OTA_DIR' уже существует."
fi

curl -sL "$B_SH_URL" -o "$B_SH_PATH"

if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать скрипт oplus.sh!"
fi
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    handle_error "Файл oplus.sh не был загружен или пуст! Проверьте URL и интернет-соединение."
fi
echo -e "${GREEN}Скрипт oplus.sh успешно загружен в $B_SH_PATH${RESET}"

# --- Шаг 5: Создание списка устройств devices.txt ---
echo -e "\n${GREEN}>>> Шаг 5: Создание списка устройств devices.txt...${RESET}"
TXT_DIR="$HOME/"
TXT_FILE="$TXT_DIR/devices.txt"

chmod 700 -R "$TXT_DIR"

echo -e "${BLUE}Создаем файл : $TXT_FILE...${RESET}"
{
  echo "OnePlus 13 IN|CPH2649IN|1B|A"
  echo "OnePlus 13 EU|CPH2653EEA|44|A"
  echo "OnePlus 13 ROW|CPH2653|A7|A"
  echo "OnePlus 13 CN|PJZ110|97|A"
  echo "OnePlus Ace5|PKG110|97|A"
  echo "OnePlus 13R IN|CPH2691IN|1B|C"
  echo "OnePlus 13R EU|CPH2645EEA|44|C"
  echo "OnePlus 13R ROW|CPH2645|A7|C"
  echo "OnePlus 13s|CPH2723IN|1B|A"
  echo "OnePlus 13T|PKX110|97|A"
  echo "OnePlus 12 IN|CPH2573IN|1B|C"
  echo "OnePlus 12 EU|CPH2581EEA|44|C"
  echo "OnePlus 12 ROW|CPH2581|A7|C"
  echo "OnePlus 12 CN|PJD110|97|C"
  echo "OnePlus Ace3|PJE110|97|C"
  echo "OnePlus 12R IN|CPH2585IN|1B|C"
  echo "OnePlus 12R EU|CPH2609EEA|44|C"
  echo "OnePlus 12R ROW|CPH2609|A7|C"
  echo "OPPO Find N5 APC|CPH2671|A4|A"
  echo "OPPO Find N5 SG|CPH2671|2C|A"
} > "$TXT_FILE"

chmod +x "$TXT_FILE"
echo -e "${GREEN}Файл 'devices.txt' успешно создан!${RESET}"

# --- Шаг 6: Создание списка устройств phone_names.txt ---
echo -e "\n${GREEN}>>> Шаг 6: Создание списка устройств phone_names.txt...${RESET}"
TXT_DIR="$HOME/"
FN_FILE="$TXT_DIR/phone_names.txt"

chmod 700 -R "$TXT_DIR"

echo -e "${BLUE}Создаем файл : $FN_FILE...${RESET}"
{
echo "    models.txt"
echo "RMX1803|Realme 2 Pro"
echo "RMX1807|Realme 2 Pro"
echo "RMX1809|Realme 2"
echo "RMX1827|Realme 3i"
echo "RMX1971|Realme Q"
echo "RMX2072|Realme X50 Pro Player Edition"
echo "RMX2111|Realme V5 5G"
echo "RMX2112|Realme V5 5G"
echo "RMX2117|Realme Q2"
echo "RMX2144|Realme X50/Realme X50m"
echo "RMX2173|Realme Q2 Pro"
echo "RMX2200|Realme V3"
echo "RMX2202|Realme GT 5G"
echo "RMX2205|Realme Q3 Pro 5G"
echo "RMX3031|Realme GT Neo 5G"
echo "RMX3092|Realme V15 5G"
echo "RMX3093|Realme V15 5G"
echo "RMX3115|Realme X7 Pro Ultra 5G"
echo "RMX3121|Realme V11 5G"
echo "RMX3122|Realme V11 5G"
echo "RMX3142|Realme Q3 Pro Carnival"
echo "RMX3161|Realme Q3 5G"
echo "RMX3461|Realme Q3s/Realme 9 5G SE"
echo "RMX3300|Realme GT2 Pro"
echo "RMX3301|Realme GT2 Pro"
echo "RMX3310|Realme GT2"
echo "RMX3311|Realme GT2"
echo "RMX3312|Realme GT2"
echo "RMX3350|Realme GT Neo Flash 5G"
echo "RMX3357|Realme GT Neo 2T"
echo "RMX3372|Realme Q5 Pro"
echo "RMX3478|Realme Q5"
echo "RMX3521|Realme 9 4G"
echo "RMX3551|Realme GT2 Master Explorer"
echo "RMX3574|Realme Q5i"
echo "RMX3360|Realme GT Master Edition"
echo "RMX3363|Realme GT Master Edition"
echo "RMX3370|Realme GT Neo2"
echo "RMX3561|Realme GT Neo3 80W"
echo "RMX3563|Realme GT Neo3 150W"
echo "RMX3371|Realme GT Neo 3T"
echo "RMX3700|Realme GT Neo5 SE"
echo "RMX3701|Realme GT Neo5 SE"
echo "RMX3706|Realme GT Neo5 150W"
echo "RMX3708|Realme GT Neo5 240W"
echo "RMX3709|Realme GT3 240W"
echo "RMX3800|Realme GT6 China"
echo "RMX3850|Realme GT Neo6 SE"
echo "RMX3820|Realme GT5 150W"
echo "RMX3823|Realme GT5 240W"
echo "RMX3851|Realme GT6"
echo "RMX3853|Realme GT 6T"
echo "RMX3852|Realme GT Neo6"
echo "RMX5060|Realme Neo7"
echo "RMX3888|Realme GT5 Pro"
echo "RMX5010|Realme GT7 Pro"
echo "RMX5011|Realme GT7 Pro"
echo "RMX5090|Realme GT7 Pro Racing Edition"
echo "RMX5061|Realme GT7"
echo "RMX6688|Realme GT7"
echo "CPH2653|OnePlus 13"
echo "CPH2655|OnePlus 13"
echo "CPH2649|OnePlus 13"
echo "PJZ110|OnePlus 13"
echo "CPH2573|OnePlus 12"
echo "CPH2581|OnePlus 12"
echo "CPH2583|OnePlus 12"
echo "PJD110|OnePlus 12"
echo "PKX110|OnePlus 13T"
echo "CPH2723|OnePlus 13s"
echo "CPH2645|OnePlus 13R"
echo "CPH2691|OnePlus 13R"
echo "PKG110|OnePlus Ace 5"
echo "ONE A0001|OnePlus ONE China"
echo "ONE A1001|OnePlus ONE China Unicom"
echo "ONE A2001|OnePlus 2 China"
echo "ONE A2003|OnePlus 2"
echo "ONE A2005|OnePlus 2 North America"
echo "ONE E1000|OnePlus X China"
echo "ONE E1001|OnePlus X China Unicom"
echo "ONE E1003|OnePlus X"
echo "ONE E1005|OnePlus X North America"
echo "ONEPLUS A3000|OnePlus 3 China / North America"
echo "ONEPLUS A3003|OnePlus 3"
echo "ONEPLUS A3010|OnePlus 3T China"
echo "ONEPLUS A3013|OnePlus 3T"
echo "ONEPLUS A5000|OnePlus 5"
echo "ONEPLUS A5010|OnePlus 5T"
echo "ONEPLUS A6000|OnePlus 6 China"
echo "ONEPLUS A6003|OnePlus 6"
echo "ONEPLUS A6010|OnePlus 6T China"
echo "ONEPLUS A6013|OnePlus 6T"
echo "GM1900|OnePlus 7 China"
echo "GM1901|OnePlus 7"
echo "GM1903|OnePlus 7"
echo "GM1905|OnePlus 7 North America / Global"
echo "GM1910|OnePlus 7 Pro China"
echo "GM1911|OnePlus 7 Pro"
echo "GM1913|OnePlus 7 Pro"
echo "GM1915|OnePlus 7 Pro North America / Global"
echo "GM1917|OnePlus 7 Pro T-Mobile"
echo "GM1920|OnePlus 7 Pro 5G"
echo "GM1925|OnePlus 7 Pro 5G Sprint"
echo "HD1900|OnePlus 7T China"
echo "HD1901|OnePlus 7T"
echo "HD1903|OnePlus 7T"
echo "HD1905|OnePlus 7T North America / Global"
echo "HD1907|OnePlus 7T T-Mobile"
echo "HD1910|OnePlus 7T Pro"
echo "HD1911|OnePlus 7T Pro"
echo "HD1913|OnePlus 7T Pro"
echo "HD1925|OnePlus 7T Pro 5G T-Mobile"
echo "IN2010|OnePlus 8 China"
echo "IN2011|OnePlus 8"
echo "IN2013|OnePlus 8"
echo "IN2015|OnePlus 8 North America / Global"
echo "IN2017|OnePlus 8 T-Mobile"
echo "IN2019|OnePlus 8 Visible / Verzion"
echo "IN2020|OnePlus 8 Pro"
echo "IN2021|OnePlus 8 Pro"
echo "IN2023|OnePlus 8 Pro"
echo "IN2025|OnePlus 8 Pro North America / Global"
echo "KB2000|OnePlus 8T"
echo "KB2001|OnePlus 8T"
echo "KB2003|OnePlus 8T"
echo "KB2005|OnePlus 8T North America / Global"
echo "KB2007|OnePlus 8T+ T-Mobile"
echo "LE2100|OnePlus 9R"
echo "LE2101|OnePlus 9R"
echo "LE2110|OnePlus 9"
echo "LE2111|OnePlus 9"
echo "LE2113|OnePlus 9"
echo "LE2115|OnePlus 9 North America"
echo "LE2117|OnePlus 9 T-Mobile"
echo "LE2119|OnePlus 9 Verzion"
echo "LE2120|OnePlus 9 Pro"
echo "LE2121|OnePlus 9 Pro"
echo "LE2123|OnePlus 9 Pro"
echo "LE2125|OnePlus 9 Pro"
echo "LE2127|OnePlus 9 Pro T-Mobile"
echo "MT2110|OnePlus 9RT"
echo "MT2111|OnePlus 9RT"
echo "NE2210|OnePlus 10 Pro"
echo "NE2211|OnePlus 10 Pro"
echo "NE2213|OnePlus 10 Pro"
echo "NE2215|OnePlus 10 Pro North America"
echo "NE2217|OnePlus 10 Pro T-Mobile"
echo "PGKM10|OnePlus Ace"
echo "CPH2423|OnePlus 10R"
echo "CPH2411|OnePlus 10R Endurance India"
echo "PGZ110|OnePlus Ace Race"
echo "PGP110|OnePlus Ace Pro"
echo "CPH2413|OnePlus 10T"
echo "CPH2415|OnePlus 10T"
echo "CPH2417|OnePlus 10T North America"
echo "CPH2419|OnePlus 10T T-Mobile"
echo "PHB110|OnePlus 11"
echo "CPH2447|OnePlus 11"
echo "CPH2449|OnePlus 11"
echo "CPH2451|OnePlus 11 North America"
echo "PHK110|OnePlus Ace 2"
echo "CPH2487|OnePlus 11R"
echo "PHP110|OnePlus Ace 2V"
echo "CPH2491|OnePlus Nord 3"
echo "CPH2493|OnePlus Nord 3"
echo "PJA110|OnePlus Ace 2 Pro"
echo "PJE110|OnePlus Ace 3"
echo "CPH2585|OnePlus 12R"
echo "CPH2609|OnePlus 12R"
echo "CPH2611|OnePlus 12R North America"
echo "PJF110|OnePlus Ace 3V"
echo "PJX110|OnePlus Ace 3 Pro"
echo "CPH2655|OnePlus 13 North America"
echo "CPH2647|OnePlus 13R"
echo "PKR110|OnePlus Ace 5 Pro"
echo "PLC110|OnePlus Ace 5 Ultra"
echo "PLF110|OnePlus Ace 5 Race"
echo "AC2001|OnePlus Nord"
echo "AC2003|OnePlus Nord"
echo "DN2101|OnePlus Nord 2"
echo "DN2103|OnePlus Nord 2"
echo "CPH2399|OnePlus Nord 2T"
echo "CPH2401|OnePlus Nord 2T"
echo "CPH2661|OnePlus Nord 4"
echo "CPH2663|OnePlus Nord 4"
echo "CPH2707|OnePlus Nord 5"
echo "CPH2709|OnePlus Nord 5"
echo "EB2101|OnePlus Nord CE"
echo "EB2103|OnePlus Nord CE"
echo "IV2201|OnePlus Nord CE 2"
echo "CPH2381|OnePlus Nord CE 2 Lite"
echo "CPH2409|OnePlus Nord CE 2 Lite"
echo "CPH2569|OnePlus Nord CE 3"
echo "CPH2465|OnePlus Nord CE 3 Lite"
echo "CPH2467|OnePlus Nord CE 3 Lite"
echo "CPH2513|OnePlus Nord N30 North America"
echo "CPH2515|OnePlus Nord N30 T-Mobile"
echo "CPH2613|OnePlus Nord CE 4"
echo "CPH2619|OnePlus Nord CE 4 Lite"
echo "CPH2621|OnePlus Nord CE 4 Lite"
echo "CPH2717|OnePlus Nord CE 5"
echo "CPH2719|OnePlus Nord CE 5"
echo "BE2025|OnePlus Nord N10 Metro"
echo "BE2026|OnePlus Nord N10 North America"
echo "BE2029|OnePlus Nord N10"
echo "BE2028|OnePlus Nord N10 T-Mobile"
echo "BE2011|OnePlus Nord N100 North America"
echo "BE2012|OnePlus Nord N100 T-Mobile"
echo "BE2013|OnePlus Nord N100"
echo "BE2015|OnePlus Nord N100 Metro"
echo "GN2200|OnePlus Nord N20"
echo "CPH2459|OnePlus Nord N20"
echo "CPH2469|OnePlus Nord 20 SE"
echo "CPH2605|OnePlus Nord N30 SE"
echo "DE2117|OnePlus Nord N200 North America"
echo "DE2118|OnePlus Nord N200 T-Mobile"
echo "CPH2389|OnePlus Nord N300"
echo "CPH2551|OnePlus Open"
echo "OPD2203|OnePlus Pad (2023)"
echo "OPD2304|OnePlus Pad Go LTE"
echo "OPD2305|OnePlus Pad Go Wi-Fi"
echo "OPD2407|OnePlus Pad (2024)"
echo "OPD2404|OnePlus Pad Pro"
echo "OPD2403|OnePlus Pad 2"
echo "OPD2413|OnePlus Pad 2 Pro"
echo "OPD2415|OnePlus Pad 3"
echo "CPH1859|Realme 1"
echo "CPH1861|Realme 1"
echo "RMX1805|Realme 2"
echo "RMX1801|Realme 2 Pro"
echo "RMX1821|Realme 3"
echo "RMX1822|Realme 3"
echo "RMX1825|Realme 3"
echo "RMX1851|Realme 3 Pro"
echo "RMX1853|Realme 3 Pro"
echo "RMX1911|Realme 5"
echo "RMX1915|Realme 5"
echo "RMX1919|Realme 5"
echo "RMX1925|Realme 5"
echo "RMX1926|Realme 5"
echo "RMX1927|Realme 5"
echo "RMX1925|Realme 5s"
echo "RMX2030|Realme 5i"
echo "RMX2031|Realme 5i"
echo "RMX2032|Realme 5i"
echo "RMX1971|Realme 5 Pro"
echo "RMX1973|Realme 5 Pro"
echo "RMX2001|Realme 6"
echo "RMX2003|Realme 6"
echo "RMX2061|Realme 6 Pro"
echo "RMX2063|Realme 6 Pro"
echo "RMX2002|Realme 6s"
echo "RMX2002|Realme 6i"
echo "RMX2040|Realme 6i"
echo "RMX2041|Realme 6i"
echo "RMX2042|Realme 6i"
echo "RMX2151|Realme 7"
echo "RMX2155|Realme 7"
echo "RMX2111|Realme 7 5G"
echo "RMX2170|Realme 7 Pro"
echo "RMX2103|Realme 7i"
echo "RMX2104|Realme 7i"
echo "RMX2193|Realme 7i"
echo "RMX3085|Realme 8"
echo "RMX3081|Realme 8 Pro"
echo "RMX3241|Realme 8 5G"
echo "RMX3151|Realme 8i"
echo "RMX3381|Realme 8s 5G"
echo "RMX3521|Realme 9"
echo "RMX3491|Realme 9i"
echo "RMX3492|Realme 9i"
echo "RMX3493|Realme 9i"
echo "RMX3612|Realme 9i 5G"
echo "RMX3388|Realme 9 5G"
echo "RMX3474|Realme 9 5G"
echo "RMX3471|Realme 9 Pro"
echo "RMX3472|Realme 9 Pro"
echo "RMX3392|Realme 9 Pro+"
echo "RMX3393|Realme 9 Pro+"
echo "RMX3630|Realme 10"
echo "RMX3660|Realme 10 Pro"
echo "RMX3661|Realme 10 Pro"
echo "RMX3686|Realme 10 Pro+"
echo "RMX3612|Realme 10T"
echo "RMX3636|Realme 11"
echo "RMX3780|Realme 11 5G"
echo "RMX3785|Realme 11x"
echo "RMX3771|Realme 11 Pro"
echo "RMX3741|Realme 11 Pro+"
echo "RMX3871|Realme 12 4G"
echo "RMX3999|Realme 12 5G"
echo "RMX3998|Realme 12x"
echo "RMX3867|Realme 12+"
echo "RMX3842|Realme 12 Pro"
echo "RMX3840|Realme 12 Pro+"
echo "RMX3871|Realme 13 4G"
echo "RMX3951|Realme 13 5G"
echo "RMX5000|Realme 13+"
echo "RMX3990|Realme 13 Pro"
echo "RMX3990|Realme 14 Pro Lite 5G"
echo "RMX3921|Realme 13 Pro+"
echo "RMX5070|Realme 14"
echo "RMX3940|Realme 14x"
echo "RMX3943|Realme 14x"
echo "RMX5074|Realme 14T"
echo "RMX5078|Realme 14T"
echo "RMX5056|Realme 14 Pro"
echo "RMX5057|Realme 14 Pro"
echo "RMX5051|Realme 14 Pro+"
echo "RMX5054|Realme 14 Pro+"
echo "RMX1901|Realme X"
echo "RMX1921|Realme XT"
echo "RMX1922|Realme XT"
echo "RMX1992|Realme X2"
echo "RMX1993|Realme X2"
echo "RMX1931|Realme X2 Pro"
echo "RMX2081|Realme X3"
echo "RMX2083|Realme X3"
echo "RMX2085|Realme X3 SuperZoom"
echo "RMX2086|Realme X3 SuperZoom"
echo "RMX2075|Realme X50 Pro"
echo "RMX2076|Realme X50 Pro"
echo "RMX3092|Realme X7"
echo "RMX2121|Realme X7 Pro"
echo "RMX3031|Realme X7 Max"
echo "RMX1805|Realme C1"
echo "RMX1941|Realme C2"
echo "RMX1942|Realme C2"
echo "RMX1943|Realme C2"
echo "RMX1945|Realme C2"
echo "RMX1946|Realme C2"
echo "RMX2020|Realme C3"
echo "RMX2021|Realme C3"
echo "RMX2022|Realme C3"
echo "RMX2027|Realme C3i Vietnam"
echo "RMX2185|Realme C11"
echo "RMX2186|Realme C11"
echo "RMX3231|Realme C11 2021"
echo "RMX2184|Realme C12"
echo "RMX2189|Realme C12"
echo "RMX2180|Realme C15"
echo "RMX2181|Realme C15"
echo "RMX2183|Realme C15"
echo "RMX2195|Realme C15 Qualcomm Edition"
echo "RMX2101|Realme C17"
echo "RMX3061|Realme C20"
echo "RMX3063|Realme C20"
echo "RMX3201|Realme C21"
echo "RMX3202|Realme C21"
echo "RMX3203|Realme C21"
echo "RMX3261|Realme C21Y"
echo "RMX3262|Realme C21Y"
echo "RMX3263|Realme C21Y"
echo "RMX3191|Realme C25"
echo "RMX3193|Realme C25"
echo "RMX3195|Realme C25s"
echo "RMX3197|Realme C25s"
echo "RMX3265|Realme C25Y"
echo "RMX3269|Realme C25Y"
echo "RMX3581|Realme C30"
echo "RMX3623|Realme C30"
echo "RMX3690|Realme C30s"
echo "RMX3501|Realme C31"
echo "RMX3502|Realme C31"
echo "RMX3503|Realme C31"
echo "RMX3624|Realme C33"
echo "RMX3627|Realme C33 2023"
echo "RMX3511|Realme C35"
echo "RMX3512|Realme C35"
echo "RMX3513|Realme C35"
echo "RMX3830|Realme C51"
echo "RMX3765|Realme C51s"
echo "RMX3760|Realme C53"
echo "RMX3762|Realme C53"
echo "RMX3710|Realme C55"
echo "RMX3834|Realme C60"
echo "RMX3939|Realme C61"
echo "RMX3930|Realme C61"
echo "RMX3933|Realme C61"
echo "RMX3939|Realme C63"
echo "RMX3950|Realme C63 5G"
echo "RMX3910|Realme C65"
echo "RMX3997|Realme C65 5G"
echo "RMX3939|Realme C65s"
echo "RMX3890|Realme C67"
echo "RMX3782|Realme C67 5G"
echo "RMX5303|Realme C71"
echo "RMX3945|Realme C73 5G"
echo "RMX3941|Realme C75"
echo "RMX3943|Realme C75 5G"
echo "RMX3963|Realme C75 5G"
echo "RMX5020|Realme C75x"
echo "RMX3834|Realme Note 50"
echo "RMX3933|Realme Note 60"
echo "RMX3938|Realme Note 60x"
echo "RMX1831|Realme U1"
echo "RMX1833|Realme U1"
echo "RMX3870|Realme P1"
echo "RMX3844|Realme P1 Pro 5G"
echo "RMX5004|Realme P1 Speed 5G"
echo "RMX3987|Realme P2 Pro 5G"
echo "RMX5070|Realme P3 5G"
echo "RMX5079|Realme P3 5G"
echo "RMX3944|Realme P3x 5G"
echo "RMX5032|Realme P3 Pro 5G"
echo "RMX5030|Realme P3 Ultra 5G"
echo "RMX5031|Realme P3 Ultra 5G"
echo "RMX2002|Realme Narzo Indonesia"
echo "RMX2040|Realme Narzo 10"
echo "RMX2020|Realme Narzo 10A"
echo "RMX2191|Realme Narzo 20"
echo "RMX2193|Realme Narzo 20"
echo "RMX2161|Realme Narzo 20 Pro"
echo "RMX2163|Realme Narzo 20 Pro"
echo "RMX2050|Realme Narzo 20A"
echo "RMX2156|Realme Narzo 30"
echo "RMX3242|Realme Narzo 30 5G"
echo "RMX2117|Realme Narzo 30 Pro 5G"
echo "RMX3171|Realme Narzo 30A"
echo "RMX3286|Realme Narzo 50"
echo "RMX3571|Realme Narzo 50 5G"
echo "RMX3572|Realme Narzo 50 5G"
echo "RMX3395|Realme Narzo 50 Pro 5G"
echo "RMX3396|Realme Narzo 50 Pro 5G"
echo "RMX3430|Realme Narzo 50A"
echo "RMX3516|Realme Narzo 50A Prime"
echo "RMX3517|Realme Narzo 50A Prime"
echo "RMX3231|Realme Narzo 50i"
echo "RMX3235|Realme Narzo 50i"
echo "RMX3506|Realme Narzo 50i Prime"
echo "RMX3761|Realme Narzo N53"
echo "RMX3710|Realme Narzo N55"
echo "RMX3750|Realme Narzo 60 5G"
echo "RMX3771|Realme Narzo 60 Pro 5G"
echo "RMX3782|Realme Narzo 60x 5G"
echo "RMX3933|Realme NARZO N61"
echo "RMX3939|Realme NARZO N63"
echo "RMX3997|Realme NARZO N65 5G"
echo "RMX3869|Realme NARZO 70 5G"
echo "RMX3868|Realme NARZO 70 Pro 5G"
echo "RMX3998|Realme NARZO 70x 5G"
echo "RMX5003|Realme NARZO 70 Turbo 5G"
echo "RMX5033|Realme NARZO 80 Pro 5G"
echo "RMX3944|Realme NARZO 80x 5G"
echo "RMX3945|Realme NARZO 80 Lite 5G"
echo "CPH1871|OPPO Find X"
echo "CPH1875|OPPO Find X"
echo "CPH2023|OPPO Find X2"
echo "CPH2025|OPPO Find X2 Pro"
echo "OPG01|OPPO Find X2 Pro (KDDI)"
echo "CPH2005|OPPO Find X2 Lite"
echo "CPH2009|OPPO Find X2 Neo"
echo "CPH2173|OPPO Find X3 Pro"
echo "OPG03|OPPO Find X3 Pro (KDDI)"
echo "CPH2145|OPPO Find X3 Lite"
echo "CPH2207|OPPO Find X3 Neo"
echo "CPH2307|OPPO Find X5"
echo "CPH2305|OPPO Find X5 Pro"
echo "CPH2371|OPPO Find X5 Lite"
echo "PKB110|OPPO Find X8"
echo "CPH2651|OPPO Find X8"
echo "PKC110|OPPO Find X8 Pro"
echo "CPH2659|OPPO Find X8 Pro"
echo "CPH2439|OPPO Find N2"
echo "CPH2437|OPPO Find N2 Flip"
echo "CPH2499|OPPO Find N3"
echo "CPH2519|OPPO Find N3 Flip"
echo "CPH2671|OPPO Find N5"
echo "CPH1917|OPPO Reno"
echo "CPH1921|OPPO Reno 5G"
echo "CPH1919|OPPO Reno 10x Zoom"
echo "CPH1983|OPPO Reno A"
echo "CPH1979|OPPO Reno Z"
echo "CPH1907|OPPO Reno 2"
echo "CPH1945|OPPO Reno 2Z"
echo "CPH1951|OPPO Reno 2Z"
echo "CPH1951RU|OPPO Reno 2Z"
echo "CPH1989|OPPO Reno 2F"
echo "CPH2043|OPPO Reno 3"
echo "A001OP|OPPO Reno 3 (SoftBank)"
echo "CPH2035|OPPO Reno 3 Pro"
echo "CPH2036|OPPO Reno 3 Pro"
echo "CPH2037|OPPO Reno 3 Pro"
echo "CPH2009|OPPO Reno 3 Pro"
echo "CPH2013|OPPO Reno 3A"
echo "A002OP|OPPO Reno 3A (SoftBank)"
echo "CPH2091|OPPO Reno 4"
echo "CPH2113|OPPO Reno 4"
echo "CPH2089|OPPO Reno 4 Pro"
echo "CPH2109|OPPO Reno 4 Pro"
echo "CPH2119|OPPO Reno 4 Lite"
echo "CPH2125|OPPO Reno 4 Lite"
echo "CPH2209|OPPO Reno 4F"
echo "CPH2065|OPPO Reno 4Z"
echo "CPH2159|OPPO Reno 5"
echo "CPH2145|OPPO Reno 5 5G"
echo "CPH2201|OPPO Reno 5 Pro"
echo "CPH2207|OPPO Reno 5 Pro 5G"
echo "CPH2205|OPPO Reno 5 Lite"
echo "CPH2199|OPPO Reno 5A"
echo "A101OP|OPPO Reno 5A (SoftBank)"
echo "CPH2217|OPPO Reno 5F"
echo "CPH2211|OPPO Reno 5Z"
echo "CPH2213|OPPO Reno 5Z"
echo "CPH2235|OPPO Reno 6"
echo "CPH2251|OPPO Reno 6 5G"
echo "CPH2247|OPPO Reno 6 Pro 5G"
echo "CPH2249|OPPO Reno 6 Pro 5G"
echo "CPH2237|OPPO Reno 6Z"
echo "CPH2365|OPPO Reno 6 Lite"
echo "CPH2363|OPPO Reno 7"
echo "CPH2371|OPPO Reno 7 5G"
echo "CPH2293|OPPO Reno 7 Pro 5G"
echo "CPH2353|OPPO Reno 7A"
echo "A201OP|OPPO Reno 7A (SoftBank)"
echo "OPG04|OPPO Reno 7A (KDDI)"
echo "CPH2343|OPPO Reno 7Z 5G|OPPO Reno 7 Lite 5G|OPPO Reno 8 Lite 5G"
echo "CPH2461|OPPO Reno 8"
echo "CPH2359|OPPO Reno 8 5G"
echo "CPH2357|OPPO Reno 8 Pro 5G"
echo "CPH2457|OPPO Reno 8Z 5G"
echo "CPH2481|OPPO Reno 8T"
echo "CPH2505|OPPO Reno 8T 5G"
echo "CPH2523|OPPO Reno 9A"
echo "A301OP|OPPO Reno 9A (SoftBank)"
echo "CPH2531|OPPO Reno 10 5G"
echo "CPH2525|OPPO Reno 10 Pro 5G"
echo "CPH2541|OPPO Reno 10 Pro 5G (Japan)"
echo "CPH2521|OPPO Reno 10 Pro+ 5G"
echo "CPH2599|OPPO Reno 11 5G"
echo "CPH2607|OPPO Reno 11 Pro 5G"
echo "CPH2603|OPPO Reno 11F 5G / OPPO Reno 11A"
echo "CPH2625|OPPO Reno 12 5G"
echo "CPH2629|OPPO Reno 12 Pro 5G"
echo "CPH2637|OPPO Reno 12F 5G / OPPO Reno 12FS 5G"
echo "CPH2689|OPPO Reno 13 5G"
echo "CPH2697|OPPO Reno 13 Pro 5G"
echo "CPH2701|OPPO Reno 13F"
echo "CPH2699|OPPO Reno 13F 5G / OPPO Reno 13A"
echo "CPH2737|OPPO Reno 14"
echo "CPH2739|OPPO Reno 14 Pro"
echo "CPH2743|OPPO Reno 14F 5G"
echo "CPH1819|OPPO F7"
echo "CPH1821|OPPO F7"
echo "CPH1859|OPPO F7 Youth"
echo "CPH1823|OPPO F9"
echo "CPH1825|OPPO F9"
echo "CPH1881|OPPO F9"
echo "CPH1911|OPPO F11"
echo "CPH1969|OPPO F11 Pro"
echo "CPH1987|OPPO F11 Pro"
echo "CPH2001|OPPO F15"
echo "CPH2095|OPPO F17"
echo "CPH2197|OPPO F19"
echo "CPH2219|OPPO F19"
echo "CPH2217|OPPO F19 Pro"
echo "CPH2285|OPPO F19 Pro"
echo "CPH2213|OPPO F19 Pro+ 5G"
echo "CPH2223|OPPO F19s"
echo "CPH2363|OPPO F21 Pro"
echo "CPH2341|OPPO F21 Pro 5G"
echo "CPH2343|OPPO F21 Pro 5G"
echo "CPH2461|OPPO F21s Pro"
echo "CPH2455|OPPO F21s Pro 5G"
echo "CPH2481|OPPO F23"
echo "CPH2527|OPPO F23 5G"
echo "CPH2603|OPPO F25 Pro 5G"
echo "CPH2637|OPPO F27 5G"
echo "CPH2643|OPPO F27 Pro+ 5G"
echo "CPH2721|OPPO F29 5G"
echo "CPH2705|OPPO F29 Pro 5G"
echo "CPH1835|OPPO R15"
echo "CPH1831|OPPO R15 Pro"
echo "CPH1833|OPPO R15 Pro"
echo "CPH1879|OPPO R17"
echo "CPH1877|OPPO R17 Pro"
echo "CPH1893|OPPO R17 Neo"
echo "CPH1893RU|OPPO R17 Neo"
echo "CPH1923|OPPO A1k"
echo "CPH1923RU|OPPO A1k"
echo "CPH1837|OPPO A3"
echo "CPH2669|OPPO A3 (2024)"
echo "CPH2639|OPPO A3 5G"
echo "CPH2683|OPPO A3 5G"
echo "A402OP|OPPO A3 5G (SoftBank)"
echo "CPH1803|OPPO A3s"
echo "CPH1853|OPPO A3s"
echo "CPH1805|OPPO A3s"
echo "CPH2641|OPPO A3x"
echo "CPH2681|OPPO A3x 5G"
echo "CPH2639|OPPO A3 Pro 5G"
echo "CPH2665|OPPO A3 Pro 5G"
echo "CPH1809|OPPO A5"
echo "CPH1909|OPPO A5s"
echo "CPH1909RU|OPPO A5s"
echo "CPH1912|OPPO A5s"
echo "CPH1851|OPPO AX5"
echo "CPH1920|OPPO AX5s"
echo "CPH1931|OPPO A5 2020"
echo "CPH1933|OPPO A5 2020"
echo "CPH1943|OPPO A5 2020"
echo "CPH2735|OPPO A5 5G"
echo "CPH2751|OPPO A5 5G"
echo "A502OP|OPPO A5 5G (SoftBank)"
echo "CPH2727|OPPO A5 (2025) / OPPO A5m"
echo "CPH2773|OPPO A5i"
echo "CPH2711|OPPO A5 Pro"
echo "CPH2695|OPPO A5 Pro 5G"
echo "CPH1901|OPPO A7"
echo "CPH1905|OPPO A7"
echo "CPH1903|OPPO AX7"
echo "CPH1893|OPPO AX7 Pro"
echo "CPH1893RU|OPPO AX7 Pro"
echo "CPH1938|OPPO A9"
echo "CPH1937|OPPO A9 2020"
echo "CPH1941|OPPO A9 2020"
echo "CPH1931|OPPO A11"
echo "CPH1941|OPPO A11"
echo "CPH1943|OPPO A11"
echo "CPH2071|OPPO A11k"
echo "CPH2083|OPPO A11k"
echo "CPH2077|OPPO A12"
echo "CPH2083|OPPO A12"
echo "CPH2185|OPPO A15"
echo "CPH2179|OPPO A15s"
echo "CPH2349|OPPO A16"
echo "CPH2351|OPPO A16"
echo "CPH2271|OPPO A16s"
echo "CPH2421|OPPO A16e"
echo "CPH2477|OPPO A17"
echo "CPH2471|OPPO A17k"
echo "CPH2591|OPPO A18"
echo "CPH2641|OPPO A20"
echo "CPH2015|OPPO A31"
echo "CPH2031|OPPO A31"
echo "CPH2073|OPPO A31"
echo "CPH2081|OPPO A31"
echo "CPH2127|OPPO A33"
echo "CPH2137|OPPO A33"
echo "CPH2579|OPPO A38"
echo "CPH2669|OPPO A40 / OPPO A40m"
echo "CPH2061|OPPO A52"
echo "CPH2069|OPPO A52"
echo "CPH2127|OPPO A53"
echo "CPH2131|OPPO A53"
echo "CPH2133|OPPO A53"
echo "CPH2137|OPPO A53"
echo "CPH2139|OPPO A53"
echo "CPH2135|OPPO A53s"
echo "CPH2321|OPPO A53s 5G"
echo "CPH2239|OPPO A54"
echo "CPH2195|OPPO A54 5G"
echo "CPH2303|OPPO A54 5G"
echo "OPG02|OPPO A54 5G (KDDI)"
echo "CPH2273|OPPO A54s"
echo "CPH2325|OPPO A55"
echo "CPH2309|OPPO A55s 5G"
echo "A102OP|OPPO A55s 5G (SoftBank)"
echo "CPH1701|OPPO A57 (2016)"
echo "CPH2387|OPPO A57"
echo "CPH2407|OPPO A57"
echo "CPH2385|OPPO A57s"
echo "CPH2577|OPPO A58"
echo "CPH2617|OPPO A59 5G"
echo "CPH2631|OPPO A60"
echo "CPH3669|OPPO A60"
echo "CPH2683|OPPO A60 5G"
echo "CPH2067|OPPO A72"
echo "CPH2095|OPPO A73"
echo "CPH2099|OPPO A73"
echo "CPH2161|OPPO A73 5G"
echo "CPH2219|OPPO A74"
echo "CPH2197|OPPO A74 5G"
echo "CPH2263|OPPO A74 5G"
echo "CPH2385|OPPO A77"
echo "CPH2339|OPPO A77 5G"
echo "CPH2473|OPPO A77s"
echo "CPH2565|OPPO A78"
echo "CPH2483|OPPO A78 5G"
echo "CPH2495|OPPO A78 5G"
echo "CPH2553|OPPO A79 5G"
echo "CPH2557|OPPO A79 5G"
echo "A303OP|OPPO A79 5G (SoftBank)"
echo "CPH2639|OPPO A80 5G"
echo "CPH2001|OPPO A91"
echo "CPH2021|OPPO A91"
echo "CPH2059|OPPO A92"
echo "CPH2121|OPPO A93"
echo "CPH2123|OPPO A93"
echo "CPH2203|OPPO A94"
echo "CPH2211|OPPO A94 5G"
echo "CPH2365|OPPO A95"
echo "CPH2333|OPPO A96"
echo "CPH2529|OPPO A98 5G"
echo "CPH1955|OPPO K3"
echo "CPH2373|OPPO K10"
echo "CPH2237|OPPO K10 5G"
echo "CPH2667|OPPO K12x 5G"
echo "CPH2729|OPPO K13 5G"
echo "CPH2753|OPPO K13x 5G"
echo "OPD2102A|OPPO Pad Air"
echo "OPD2202|OPPO Pad 2"
echo "OPD2302|OPPO Pad Neo Wi-Fi"
echo "OPD2303|OPPO Pad Neo LTE"
echo "OPD2406|OPPO Pad 3"
echo "OPD2402|OPPO Pad 3 Pro"
echo "OPD2419|OPPO Pad SE Wi-Fi"
echo "OPD2420|OPPO Pad SE LTE"
} > "$FN_FILE"

chmod +x "$FN_FILE"
echo -e "${GREEN}Файл 'phone_names.txt' успешно создан!${RESET}"

# --- Шаг 7: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 7: Создание ярлыка...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/OTAFindeR"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

echo -e "${BLUE}Создаем файл ярлыка: $SHORTCUT_FILE...${RESET}"

cat "$B_SH_PATH" >> "$SHORTCUT_FILE"

chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'OTAFindeR' успешно создан!${RESET}"

# --- ЗАВЕРШЕНИЕ ---
clear
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}     🎉 Установка успешно завершена! 🎉     ${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo ""
echo -e "${YELLOW}Что делать дальше:${RESET}"
echo "1. Полностью закройте приложение Termux (командой 'exit')."
echo "2. Перейдите на главный экран вашего телефона."
echo "3. Добавьте виджет 'Termux'."
echo "4. В списке доступных ярлыков должен появиться 'OTAFindeR'."
echo "5. Нажмите на него, чтобы запустить скрипт поиска обновлений."
echo ""
echo -e "${BLUE}С Вами был${RESET}" "${RED}SeRViP!${RESET}"
