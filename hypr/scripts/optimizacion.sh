#!/usr/bin/env bash

echo ' Leviathan'

A="󰣇 Actualizar el Leviathan"
LC="󱝥 Limpiar cache"
LP="󱝧 Limpiar paquetes huerfanos"
B="󱎴 BTOP"
S="Si, el leviathan resurgirá"
N="No, mantenerlo despierto"
upd_c=$(yay -Qu | wc -l)

terminal() {
    local cmd="$1"

    kitty -e bash -c "
        $cmd
        echo
        read -p 'Pulsa Enter para continuar...'
    " &

    local pid=$!
    wait "$pid"
}

menu() {
	
	local paq_c=$(pacman -Qtdq | wc -w)
	local cache_c=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f 1)

	printf "%s\n%s\n%s\n%s\n%s\n" \
	"$A ($upd_c)" \
	"$LC ($cache_c)" \
	"$LP ($paq_c)" \
	"$B" \
	"󰜺 Cancelar" |
	rofi -dmenu \
	-p "¿Qué desea hacer?" \
	-i \
	-theme-str 'window{width: 400px; height: 210px;}'
}

conf() {
	printf "%s\n%s\n" \
	"$S" \
	"$N" |
	rofi -dmenu \
	-p "¿Quiere reiniciar al Leviathan?" \
	-i \
	-theme-str 'window{width: 275px; height: 130px;}'
}

actualizar() {
	terminal "yay -Syu"
	if [ "$(conf)" = "$S" ]
	then systemctl reboot
	fi
}


while true; do
	case $(menu) in
	"$A"*)
	if (( "$upd_c" > 0 ));
	then actualizar
	fi
	exit 0
	;;
	"$LC"*) terminal "sudo paccache -r"
	exit 0
	;;
	"$LP"*)
	terminal 'sudo pacman -Rns $(pacman -Qdtq)'
	exit 0
	;;
	"$B")
	terminal "btop"
	exit 0
	;;
	*)
	break
	;;
	esac
done
