#!/bin/bash
#
# Скрипт для автоматической установки СПО Справки БК 3.0.4 (Linux)
# 0.3
# 03.10.2025
#
# Запуск скрипта одной командой из терминала
# Сеть TUGEN (г. Владивосток):
# wget http://194.154.68.13/soft/sh/quick_sbk.sh && chmod +x quick_sbk.sh && bash quick_sbk.sh
# wget http://194.154.68.13/soft/sh/quick_sbk.sh && chmod +x quick_sbk.sh && sudo bash quick_sbk.sh
# Сеть VSPD (Любой узел в сети Ростехнадзора):
# wget http://10.9.103.3:8088/soft/sh/quick_sbk.sh && chmod +x quick_sbk.sh && bash quick_sbk.sh
# wget http://10.9.103.3:8088/soft/sh/quick_sbk.sh && chmod +x quick_sbk.sh && sudo bash quick_sbk.sh

# Форматирование цветом: echo -e "${BRED} text text ${NC}"
# Жирный красный шрифт (Bold Red)
BRED="\033[1;31m"
# Жирный зеленый шрифт (Bold Green)
BGREEN="\033[1;32m"
# Жирный жёлтый шрифт (Bold Yellow)
BYELLOW="\033[1;33m"
# Шрифт без форматирования (No Color)
NC="\033[0m"

# Прямая ссылка на загрузку архива с сайта kremlin.ru и контрольная сумма (MD5) архива
# http://www.kremlin.ru/structure/additional/12
# Актуально на 26.09.2025
SBKURL=http://static.kremlin.ru/media/events/files/ru/PfeduNqcAbHLYz417zjB3RYqeKLBONCJ.zip
MD5SUM=0117a6c9601f7f31692d171e09447680

FILENAME=$(echo "$SBKURL" | sed 's|.*files/ru/||')

DELETE_MODE=false
# Обработка аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--delete)
            DELETE_MODE=true
            shift
            ;;
		-h|--help)
            echo "Использование: $0 [-d] [-v] [-o файл]"
            echo "  -d, --delete    Режим удаления СПО Справки БК"
            echo "  -h, --help      Справка по аргументам"
			rm -f quick_sbk.sh
            exit 0
            ;;
        *)
			echo -e "${BRED}Неизвестный аргумент: $1 ${NC}"
			echo -e "${BRED}Используйте $0 -h для справки ${NC}"
			echo
			rm -f quick_sbk.sh
            exit 1
            ;;
    esac
done

if [ "$DELETE_MODE" = "true" ]; then
	# Удаляем папку с программой и ярлыки в меню в зависимости от пользователя (root / user)
	if [ "$(id -u)" = "0" ]; then
		rm -rf /opt/spravki-bk
		rm -f /usr/share/applications/spravki-bk.desktop
		echo -e "${BGREEN}Удаление СПО Справки БК завершено! ${NC}"
		echo
		
	else
		rm -rf $HOME/.soft/spravki-bk
		rm -f $HOME/.local/share/applications/spravki-bk.desktop
		rm -f "$HOME/Рабочий стол/spravki-bk.desktop"
		echo -e "${BGREEN}Удаление СПО Справки БК завершено! ${NC}"
		echo
		
	fi
	
else
	if [ "$(id -u)" = "0" ]; then
		# Загрузка архива с сайта kremlin.ru
		wget -nc $SBKURL -P /tmp/spravkibk
		# Проверяем контрольную сумму загруженного архива
		if [ "$(md5sum /tmp/spravkibk/$FILENAME | awk '{print $1}')" = $MD5SUM ]; then
			# Распаковываем архив и deb пакет
			unzip -o /tmp/spravkibk/$FILENAME -d /tmp/spravkibk/
			ar x /tmp/spravkibk/SpravkiBk-3-0-4-2591-Internet.deb --output /tmp/spravkibk/
			tar -xvf /tmp/spravkibk/data.tar.gz -C /tmp/spravkibk/
			# Установка программы в папку /opt/ и добавление ярлыка запуска в главное меню Mate - Офис - СПО Справки БК
			cp -r /tmp/spravkibk/opt/spravki-bk /opt/spravki-bk
			# Создаём ярлык запуска приложения в меню Mate - Офис - СПО Справки БК
			{
				echo '[Desktop Entry]'
				echo 'Version=3.0.4'
				echo 'Name=СПО Справки БК'
				echo 'Comment=Специальное программное обеспечение Справки БК'
				echo 'Exec=/opt/spravki-bk/sbk'
				echo 'Icon=/opt/spravki-bk/resources/bin/ClientApp/build/logo192.png'
				echo 'Type=Application'
				echo 'Categories=Office;'
			} >> /usr/share/applications/spravki-bk.desktop
			# Удаление временной папки
			rm -rf /tmp/spravkibk
			echo -e "${BGREEN}Установка СПО Справки БК завершена! ${NC}"
			echo -e "Запуск программы из главного меню: ${BGREEN}Меню - Офис - СПО Справки БК ${NC}"
			
		else
			echo -e "${BRED}Контрольная сумма (MD5) $FILENAME не совпадает с референсным значением ${NC}"
			echo -e "${BRED}$(md5sum /tmp/spravkibk/$FILENAME | awk '{print $1}') : $MD5SUM ${NC}"
			echo "Папка /tmp/spravkibk удалена со всем содержимым, презапустите скрипт"
			rm -rf /tmp/spravkibk
			rm -f quick_sbk.sh
			exit 1
			
		fi
	
	else
		# Загрузка архива с сайта
		wget -nc $SBKURL -P /tmp/spravkibk
		# Проверяем контрольную сумму загруженного архива
		if [ "$(md5sum /tmp/spravkibk/$FILENAME | awk '{print $1}')" = $MD5SUM ]; then
			# Распаковываем архив и deb пакет
			unzip -o /tmp/spravkibk/$FILENAME -d /tmp/spravkibk/
			ar x /tmp/spravkibk/SpravkiBk-3-0-4-2591-Internet.deb --output /tmp/spravkibk/
			tar -xvf /tmp/spravkibk/data.tar.gz -C /tmp/spravkibk/
			# Установка программы в домашнюю папку пользователя и добавление ярлыка запуска на рабочий стол и в меню запуска
			mkdir $HOME/.soft
			cp -r /tmp/spravkibk/opt/spravki-bk $HOME/.soft/spravki-bk
			# Создаём ярлык запуска приложения в меню Mate - Офис - СПО Справки БК
			{
				echo '[Desktop Entry]'
				echo 'Version=3.0.4'
				echo 'Name=СПО Справки БК'
				echo 'Comment=Специальное программное обеспечение Справки БК'
				echo Exec="$HOME/.soft/spravki-bk/sbk"
				echo Icon="$HOME/.soft/spravki-bk/resources/bin/ClientApp/build/logo192.png"
				echo 'Type=Application'
				echo 'Categories=Office;'
			} >> $HOME/.local/share/applications/spravki-bk.desktop
			# Создаём ярлык запуска на рабочем столе
			{
				echo '[Desktop Entry]'
				echo 'Version=3.0.4'
				echo 'Name=СПО Справки БК'
				echo 'Comment=Специальное программное обеспечение Справки БК'
				echo Exec="$HOME/.soft/spravki-bk/sbk"
				echo Icon="$HOME/.soft/spravki-bk/resources/bin/ClientApp/build/logo192.png"
				echo 'Type=Application'
				echo 'Categories=Office;'
			} >> "$HOME/Рабочий стол/spravki-bk.desktop"
			# Удаление временной папки
			rm -rf /tmp/spravkibk
			echo -e "${BGREEN}Установка СПО Справки БК завершена! ${NC}"
			echo -e "Запуск программы из главного меню: ${BGREEN}Меню - Офис - СПО Справки БК ${NC}"
			
		else
			echo -e "${BRED}Контрольная сумма (MD5) $FILENAME не совпадает с референсным значением ${NC}"
			echo -e "${BRED}$(md5sum /tmp/spravkibk/$FILENAME | awk '{print $1}') : $MD5SUM ${NC}"
			echo "Папка /tmp/spravkibk удалена со всем содержимым, презапустите скрипт"
			rm -rf /tmp/spravkibk
			rm -f quick_sbk.sh
			exit 1
			
		fi
	
	fi
	
fi

rm -f quick_sbk.sh
exit 0