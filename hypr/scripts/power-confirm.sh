#!/usr/bin/env bash

NO=" No, cancelar acción"
SI=" Sí, ave a Leviathan"

A=" Apagar"
R=" Reiniciar"
C=" Cancelar"

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
		-p "¿Qué desea realizar?" \
		-i \
		-theme-str 'window{width: 350px; height: 160px;}'
}

while true; do
case "$(menu)" in
	"$A")
	if [ "$(seguro '¿Ha llegado el final?')" = "$SI" ]
	then
		systemctl poweroff
	fi
	;;
	"$R")
	if [ "$(seguro 'Volveremos a levantarnos')" = "$SI" ]
	then
		systemctl reboot
	fi
	;;
	*)
	exit 0
	;;
esac
done
