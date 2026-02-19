#!/bin/bash

set +e

# 🛠 Automatically mod
export DEBIAN_FRONTEND=noninteractive
export TERM=xterm

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/ota_tool.sh"
ARBSCAN_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/arbscan"
REPO="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/main"

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="$HOME/OTA"
B_SH_PATH="$OTA_DIR/ota_tool.sh"
REALME_OTA_BIN="/data/data/com.termux/files/usr/bin/realme-ota"
ARBSCAN_BIN="/data/data/com.termux/files/usr/bin/arbscan"

# Вывод ошибки
handle_error() {
    echo -e "\n${RED}ОШИБКА: $1${RESET}"
    echo -e "${YELLOW}Установка прервана.${RESET}"
    exit 1
}

# --- НАЧАЛО СКРИПТА ---
clear
echo -e "${BLUE}=====================================================${RESET}"
echo -e "${BLUE}==  Автоматический установщик OTATools  by SeRViP  ==${RESET}"
echo -e "${BLUE}=====================================================${RESET}"
echo ""
echo -e "${YELLOW}Этот скрипт автоматически скачает и настроит всё необходимое.${RESET}"
read -p "Нажмите [Enter] для начала..."

# --- Шаг 1: Настройка хранилища и обновление пакетов ---
echo -e "\n${GREEN}>>> Шаг 1: Настройка хранилища и обновление системы...${RESET}"
echo " "
termux-setup-storage
mkdir -p "$OTA_DIR" || handle_error "Не удалось создать папку $OTA_DIR."
echo " "
echo "📦 Fixing broken packages and cleaning up..."
echo " "
dpkg --configure -a || true
apt --fix-broken install -y || true
apt clean
echo " "
echo "📦 Updating Termux and installing dependencies..."
echo " "
yes "" | pkg update -y
yes "" | pkg upgrade -y
echo " "
echo -e "${GREEN}Система Termux успешно обновлена.${RESET}"
echo " "

# --- Шаг 2: Установка Python модулей и зависимостей ---
echo -e "\n${GREEN}>>> Шаг 2: Установка системных пакетов (python, git, tsu)...${RESET}"
echo " "
echo "📦 Installing required packages..."
echo " "
pkg install aria2 -y
pkg install -y python python2 git tsu curl
pip install wheel
pip install pycryptodome
pip3 install --upgrade requests pycryptodome git+https://github.com/R0rt1z2/realme-ota
pip install aiohttp
echo " "

# Права доступа
if [ -f "$REALME_OTA_BIN" ]; then
    echo -e "${BLUE}Назначаем права на исполнение для realme-ota...${RESET}"
    chmod +x "$REALME_OTA_BIN"
else
    echo -e "${YELLOW}ПРЕДУПРЕЖДЕНИЕ: Не найден файл $REALME_OTA_BIN. Возможны проблемы в работе.${RESET}"
fi
echo -e "${GREEN}Python-модули и зависимости успешно установлены и настроены.${RESET}"

# --- Шаг 3: Загрузка скрипта ota_tool.sh ---
echo -e "\n${GREEN}>>> Шаг 3: 📥 Загрузка скрипта (ota_tool.sh)...${RESET}"
echo " "
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
echo " "
curl -sL "$B_SH_URL" -o "$B_SH_PATH"
echo " "
if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать скрипт ota_tool.sh!"
fi
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    handle_error "Файл ota_tool.sh не был загружен или пуст! Проверьте URL и интернет-соединение."
fi
echo " "
echo -e "${GREEN}Скрипт ota_tool.sh успешно загружен в $B_SH_PATH${RESET}"
echo " "

# --- Шаг 4: Загрузка других скриптов ---
echo -e "\n${GREEN}>>> Шаг 4: 📥 Загрузка скриптов ...${RESET}"
echo " "
for file in oplus.sh sharelink.sh downloader.sh edl_finder.py check_arb.sh phone_name.txt phone_names.txt devices.txt; do
    echo "➡️  $file"
    http_code=$(curl -L -w "%{http_code}" -o "$file" "$REPO/$file")

    if [[ "$http_code" != "200" ]]; then
        echo "❌ Failed to download $file (HTTP $http_code)"
        rm -f "$file"
        exit 1
    fi
done
echo " "
echo "✅ All files downloaded successfully"
chmod +x oplus.sh sharelink.sh downloader.sh edl_finder.py check_arb.sh

# --- Шаг 5: Загрузка ARBSCAN ---
echo -e "\n${GREEN}>>> Шаг 5: 📥 Загрузка ARBScan...${RESET}"
echo " "
curl -sL "$ARBSCAN_URL" -o "$ARBSCAN_BIN"
echo " "
if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать скрипт arbscan!"
fi
if [ ! -f "$ARBSCAN_BIN" ] || [ ! -s "$ARBSCAN_BIN" ]; then
    handle_error "Файл arbscan не был загружен или пуст! Проверьте URL и интернет-соединение."
fi
echo " "
echo -e "${GREEN}Скрипт arbscan успешно загружен в $ARBSCAN_BIN${RESET}"

# Права доступа
if [ -f "$ARBSCAN_BIN" ]; then
    echo -e "${BLUE}Назначаем права на исполнение для arbscan...${RESET}"
    chmod +x "$ARBSCAN_BIN"
else
    echo -e "${YELLOW}ПРЕДУПРЕЖДЕНИЕ: Не найден файл $ARBSCAN_BIN. Возможны проблемы в работе.${RESET}"
fi

# --- Шаг 6: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 6: 🛠️ Создание ярлыка...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/OTATools"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

echo -e "${BLUE}Создаем файл ярлыка: $SHORTCUT_FILE...${RESET}"

cat "$B_SH_PATH" >> "$SHORTCUT_FILE"

chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'OTATools' успешно создан!${RESET}"

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
