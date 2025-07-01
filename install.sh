#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/oplus.sh"
TXT_SH_URL="https://raw.githubusercontent.com/EvGRaF87/OTAFinder/refs/heads/main/oneplus.txt"

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="$HOME/OTA"
B_SH_PATH="$OTA_DIR/oplus.sh"
TXT_SH_PATH="$OTA_DIR/oneplus.txt"
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

curl -sL "$TXT_SH_URL" -o "$TXT_SH_PATH"

if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать файл oneplus.txt!"
fi
if [ ! -f "$TXT_SH_PATH" ] || [ ! -s "$TXT_SH_PATH" ]; then
    handle_error "Файл oneplus.txt не был загружен или пуст!"
fi
echo -e "${GREEN}Файл oneplus.txt успешно загружен в $B_SH_PATH${RESET}"

echo -e "${BLUE}Создаем файл : $TXT_FILE...${RESET}"
{
  cat "$TXT_SH_PATH"
} > "$TXT_FILE"

# --- Шаг 6: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 6: Создание ярлыка...${RESET}"
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
echo -e "${GREEN}     🎉 Установка успешно завершена! 🎉     ${RESET}"
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
