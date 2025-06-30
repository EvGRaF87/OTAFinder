#!/bin/bash

# ==============================================================================
# ==         Aвтоматический установщик OTAFindeR           ==
# ==============================================================================

# Глобально отключаем интерактивные вопросы от установщика пакетов
export DEBIAN_FRONTEND=noninteractive

# --- НАСТРОЙКИ ---
# Исправленные URL-адреса для прямого доступа к файлам на GitHub
B_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/oplus.sh"
# --- КОНЕЦ НАСТРОЕК ---

# Цвета для красивого вывода
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="/storage/emulated/0/OTA"
B_SH_PATH="$OTA_DIR/oplus.sh"
REALME_OTA_BIN="/data/data/com.termux/files/usr/bin/realme-ota"

# Функция для вывода ошибки и выхода
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

# --- Шаг 2: Установка системных зависимостей ---
echo -e "\n${GREEN}>>> Шаг 2: Установка системных пакетов (python, git, tsu)...${RESET}"
pkg install -y $DPKG_OPTIONS python python2 git tsu curl || handle_error "Не удалось установить системные пакеты."
echo -e "${GREEN}Все системные пакеты установлены.${RESET}"

# --- Шаг 3: Установка Python-модулей ---
echo -e "\n${GREEN}>>> Шаг 3: Установка Python-модулей...${RESET}"
pip install --upgrade pip wheel pycryptodome || handle_error "Не удалось установить wheel или pycryptodome."
pip3 install --upgrade requests pycryptodome git+https://github.com/R0rt1z2/realme-ota || handle_error "Не удалось установить realme-ota."

# Проверка и исправление прав доступа
if [ -f "$REALME_OTA_BIN" ]; then
    echo -e "${BLUE}Назначаем права на исполнение для realme-ota...${RESET}"
    chmod +x "$REALME_OTA_BIN"
else
    echo -e "${YELLOW}ПРЕДУПРЕЖДЕНИЕ: Не найден файл $REALME_OTA_BIN. Возможны проблемы в работе.${RESET}"
fi
echo -e "${GREEN}Python-модули успешно установлены и настроены.${RESET}"

# --- Шаг 4: Загрузка основного скрипта oplus.sh ---
echo -e "\n${GREEN}>>> Шаг 4: Загрузка основного скрипта (oplus.sh)...${RESET}"
curl -sL "$B_SH_URL" -o "$B_SH_PATH"
# Добавляем проверку статуса выхода curl
if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать скрипт oplus.sh! Ошибка сети или проблема с URL: $B_SH_URL"
fi
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    handle_error "Файл oplus.sh не был загружен или пуст! Проверьте URL и интернет-соединение."
fi
echo -e "${GREEN}Скрипт oplus.sh успешно загружен в $B_SH_PATH${RESET}"

# --- Шаг 5: Создание списка устройств devices.txt ---
echo -e "\n${GREEN}>>> Шаг 5: Автоматическое создание списка устройств devices.txt...${RESET}"
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
echo "OnePlus 13R IN|CPH2691IN|1B|A"
echo "OnePlus 13R EU|CPH2645EEA|44|A"
echo "OnePlus 13R ROW|CPH2645|A7|A"
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

# --- Шаг 6: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 6: Автоматическое создание ярлыка...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/OTAFindeR"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

echo -e "${BLUE}Создаем файл ярлыка: $SHORTCUT_FILE...${RESET}"
{
    echo "#!/bin/bash"
    echo "bash $B_SH_PATH"
} > "$SHORTCUT_FILE"

chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'OTAFindeR' успешно создан!${RESET}"

# --- ЗАВЕРШЕНИЕ ---
clear
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}    🎉 Установка успешно завершена! 🎉      ${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo ""
echo -e "${YELLOW}Что делать дальше:${RESET}"
echo "1. Полностью закройте приложение Termux (командой 'exit' или через меню)."
echo "2. Перейдите на главный экран вашего телефона."
echo "3. Добавьте виджет 'Termux'."
echo "4. В списке доступных ярлыков должен появиться 'OTAFindeR'."
echo "5. Нажмите на него, чтобы запустить скрипт поиска обновлений."
echo ""
echo -e "${BLUE}С Вами был SeRViP!${RESET}"
