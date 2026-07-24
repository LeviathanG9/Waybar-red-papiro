#!/usr/bin/env bash

echo ' Leviathan'

lang=${LANG%%_*}
lang=${lang,,}

case "$lang" in
	es)
		A="󰣇 Actualizar sistema"
		LC="󱝥 Limpiar caché"
		LP="󱝧 Limpiar paquetes huerfanos"
		B="󱎴 BTOP"
		S="Si"
		N="No"
		C="󰜺 Cancelar"
		Con="Pulsa Enter para continuar..."
		Q_1="¿Qué desea hacer?"
		;;
	*)
		A="󰣇 System update"
		LC="󱝥 Free Cache memory"
		LP="󱝧 Free orphan packages"
		B="󱎴 BTOP"
		S="Yes"
		N="No"
		C="󰜺 Cancel"
		Con="Press Return to continue..."
		Q_1="¿What to do?"
		;;
esac

upd_c=$(yay -Qu | wc -l)

terminal() {
    local cmd="$1"

    kitty -e bash -c "
        $cmd
        echo
        read -p "$Con"
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
	"$C" |
	rofi -dmenu \
	-p "$Q_1" \
	-i \
	-theme-str 'window{width: 400px; height: 210px;}'
}

conf() {
	printf "%s\n%s\n" \
	"$S" \
	"$N" |
	rofi -dmenu \
	-p "¿Reiniciar?" \
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
