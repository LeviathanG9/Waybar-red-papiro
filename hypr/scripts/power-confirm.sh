#!/usr/bin/env bash

lang=${LANG%%_*}
lang=${lang,,}

case "$lang" in
	es)
		NO=" No, cancelar acción"
		SI=" Sí, adiós"
		A=" Apagar"
		R=" Reiniciar"
		C=" Cancelar"
		Q_1="¿Qué desea realizar?"
	;;
	*)
		NO=" No, cancel action"
		SI=" Yeah, good bye"
		A=" Power off"
		R=" Reboot"
		C=" Cancel"
		Q_1="¿What to do?"
	;;
esac



seguro() {
	local M="$1"

	printf "%s\n%s\n" "$NO" "$SI" |
	rofi -dmenu \
	-p "$M" \
	-i \
	-theme-str 'window{width: 350px; height: 160px;}'
}

menu() {
	printf "%s\n%s\n%s\n" \
		"$A" \
		"$R" \
		"$C" |
		rofi -dmenu \
		-p "$Q_1" \
		-i \
		-theme-str 'window{width: 350px; height: 160px;}'
}

while true; do
case "$(menu)" in
	"$A")
	if [ "$(seguro $A)" = "$SI" ]
	then
		systemctl poweroff
	fi
	;;
	"$R")
	if [ "$(seguro $R)" = "$SI" ]
	then
		systemctl reboot
	fi
	;;
	*)
	exit 0
	;;
esac
done
