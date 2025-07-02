#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/real.sh"
# --- КОНЕЦ НАСТРОЕК ---

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="$HOME/OTA"
B_SH_PATH="$OTA_DIR/real.sh"
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

# --- Шаг 4: Загрузка скрипта ---
echo -e "\n${GREEN}>>> Шаг 4: Загрузка скрипта (real.sh)...${RESET}"

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
    handle_error "Не удалось скачать скрипт real.sh!"
fi
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    handle_error "Файл real.sh не был загружен или пуст! Проверьте URL и интернет-соединение."
fi
echo -e "${GREEN}Скрипт real.sh успешно загружен в $B_SH_PATH${RESET}"

# --- Шаг 5: Создание списка устройств realme.txt ---
echo -e "\n${GREEN}>>> Шаг 5: Создание списка устройств realme.txt...${RESET}"
TXT_DIR="$HOME/"
TXT_FILE="$TXT_DIR/realme.txt"

chmod 700 -R "$TXT_DIR"

echo -e "${BLUE}Создаем файл : $TXT_FILE...${RESET}"
{
echo "Realme GTNeo6|RMX3852|97|C"
echo "Realme GTNeo6SE|RMX3850|97|C"
echo "Realme GT6|RMX3851IN|1B|C"
echo "Realme GT6T|RMX3853IN|1B|C"
echo "Realme GT6|RMX3851EEA|44|C"
echo "Realme GT6T|RMX3853EEA|44|C"
echo "Realme GT6|RMX3851RU|37|C"
echo "Realme GT6T|RMX3853RU|37|C"
echo "Realme GT7Pro RE|RMX5090|97|A"
echo "Realme GT7Pro|RMX5010|97|A"
echo "Realme GT7Pro|RMX5011IN|1B|A"
echo "Realme GT7Pro|RMX5011EEA|44|A"
echo "Realme GT7Pro|RMX5011RU|37|A"
echo "Realme GT5Pro|RMX3888|97|C"
echo "Realme GT6CN|RMX3800|97|C"
echo "Realme GTNeo5 150W|RMX3706|97|F"
echo "Realme GTNeo5 240W|RMX3708|97|F"
echo "Realme GTNeo5SE|RMX3700|97|F"
echo "Realme GT3 RU|RMX3709RU|37|F"
echo "Realme GTNeo5SE|RMX3701|A6|F"
} > "$TXT_FILE"

chmod +x "$TXT_FILE"
echo -e "${GREEN}Файл 'realme.txt' успешно создан!${RESET}"

# --- Шаг 6: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 6: Автоматическое создание ярлыка...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/FindeReal"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

echo -e "${BLUE}Создаем файл ярлыка: $SHORTCUT_FILE...${RESET}"
cp "$B_SH_PATH" "$SHORTCUT_FILE"

chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'FindeReal' успешно создан!${RESET}"

# --- ЗАВЕРШЕНИЕ ---
clear
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}     🎉 Установка успешно завершена! 🎉      ${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo ""
echo -e "${YELLOW}Что делать дальше:${RESET}"
echo "1. Полностью закройте приложение Termux (командой 'exit')."
echo "2. Перейдите на главный экран вашего телефона."
echo "3. Добавьте виджет 'Termux'."
echo "4. В списке доступных ярлыков должен появиться 'FindeReal'."
echo "5. Нажмите на него, чтобы запустить скрипт поиска обновлений."
echo ""
echo -e "${BLUE}С Вами был${RESET}" "${RED}SeRViP!${RESET}"
