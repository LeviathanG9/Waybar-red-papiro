#!/usr/bin/env bash

lang=${LANG%%_*}
lang=${lang,,}

case "$lang" in
	es)
		C="󰜺 Cancelar"
		A=" Actualizar redes WiFi"
		P_1="Rofi no encontrado."
		P_2="NetworkManager no está instalado."
		open_red="Abierta"
		pwdq="Contraseña para: "
		MA_1=" Activar modo avión"
		MA_2="󰖪 Desactivar modo avión"
		n_B="Banda"
		n_Sig="Señal"
		n_Seg="Seguridad"
		title="Configuración WiFi: "
		IO="Opción no válida"
	;;
	*)
		C="󰜺 Cancel"
		A=" Update WiFi networks"
		P_1="Rofi not found."
		P_2="NetworkManager not instaled."
		open_red="Open"
		pwdq="Password for: "
		MA_1=" Activate plane mode"
		MA_2="󰖪 Desactivate plane mode"
		n_B="Bandwith"
		n_Sig="Strength"
		n_Seg="Security"
		title="WiFi Configuration: "
		IO="Invalid option."
	;;
esac

command -v rofi >/dev/null || {
    echo "$P_1"
    exit 1
}

command -v nmcli >/dev/null || {
    rofi -e "$P_2"
    exit 1
}



WIFI_DEV() {
	local type dev
	gdbus call \
	--system \
	--dest org.freedesktop.NetworkManager \
	--object-path /org/freedesktop/NetworkManager \
	--method org.freedesktop.NetworkManager.GetDevices |
	grep -o "/org/freedesktop/NetworkManager/Devices/[0-9]\+" |
	while read -r dev
	do
		type=$(
			gdbus call \
			--system \
			--dest org.freedesktop.NetworkManager \
			--object-path "$dev" \
			--method org.freedesktop.DBus.Properties.Get \
			org.freedesktop.NetworkManager.Device \
			DeviceType |
			grep -oE '[0-9]+' |
			tail -1
		)

	((type == 2)) && {
		printf "%s" "$dev"
		return
	}
	done
}

UPD() {
	gdbus call \
		--system \
		--dest org.freedesktop.NetworkManager \
		--object-path "$(WIFI_DEV)" \
		--method org.freedesktop.NetworkManager.Device.Wireless.RequestScan \
		"{}"
}
UPD
DBusProp() {
    gdbus call \
        --system \
        --dest org.freedesktop.NetworkManager \
        --object-path "$1" \
        --method org.freedesktop.DBus.Properties.Get \
        org.freedesktop.NetworkManager.AccessPoint \
        "$2"
}

SSID() {
	DBusProp "$1" Ssid |
		grep -oE '0x[0-9a-fA-F]{2}' |
		while read -r hex
		do
			printf "\\x${hex#0x}"
		done
}

STR() {
	DBusProp "$1" Strength |
		grep -oE '0x[0-9a-fa-f]{2}' |
		xargs printf "%d\n"
}

SEC() {
	local flags
	flags=$(
		DBusProp "$1" RsnFlags |
		grep -oE '[0-9]+' |
		tail -1
	)

	(( flags & 1024 )) && {
		printf "WPA3"
		return
	}
	(( flags & 256 )) && {
		printf "WPA2"
		return
	}
	(( flags & 512 )) && {
		printf "ENT"
		return
	}
	(( flags == 0 )) && {
		printf "$open_red"
		return
	}
	
}

BAND() {
	local b=$(
		DBusProp "$1" Frequency |
		grep -oE '[0-9]+' |
		tail -1
	)

	if  (( b >= 902 && b <= 928 )); then
		printf "900MHz"
		return
	elif (( b >= 2400 && b <= 2500 )); then
		printf "2.4GHz"
		return
	elif (( b >= 3650 && b <= 3700 )); then
		printf "3.6GHz"
		return
	elif (( b >= 5000 && b <= 5900 )); then
		printf "5GHz"
		return
	elif (( b >= 5925 && b <= 7125 )); then
		printf "6Ghz"
		return
	elif (( b >= 57000 && b <= 71000 )); then
		printf "60GHz!"
		return
	else
		printf "%dMHz" "$b"
		return
	fi
}

PLEN() {
	if [[ $(nmcli radio wifi) == enabled ]]; then
	        nmcli radio wifi off
	    else
	        nmcli radio wifi on
	        UPD
    fi
}

LINK() {
	local ap ssid sec pass
	ap="/org/freedesktop/NetworkManager/AccessPoint/$1"
	ssid=$(SSID "$ap")
	sec=$(SEC "$ap")
	
	if nmcli dev wifi connect "$ssid"; then
		return
	fi

	if [[ "$sec" == "$open_red" ]]; then
		nmcli dev wifi connect "$ssid"
		return
	fi

	while true
	do
		pass=$(
			rofi -dmenu \
				-password \
				-p "$pwdq $ssid: "
		)
	
		[[ -z "$pass" ]] && return

		if nmcli dev wifi connect "$ssid" password "$pass"; then
			break
		fi
		
	done
}

WiFi_menu_p() { {
	wifi_on=$(nmcli radio wifi)
	if [[ $wifi_on == enabled ]]; then
	    MA="$MA_1"
	else
	    MA="$MA_2"
	fi
	printf "%s\n%s\n%s\n%s\n"  \
	"$A" "$MA" "$C" \
	"───────────────────────────────"
		
    printf "%-5s %-35s %-6s %s %-5s\n" "AP" "SSID" "$n_B" "$n_Sig" "$n_Seg"
	(
	gdbus call \
		--system \
		--dest org.freedesktop.NetworkManager \
		--object-path "$(WIFI_DEV)" \
		--method org.freedesktop.NetworkManager.Device.Wireless.GetAllAccessPoints \
		| grep -o "/org/freedesktop/NetworkManager/AccessPoint/[0-9]\+" \
		| while read -r ap
		do
			ssid=$(SSID "$ap")
			[[ -z "$ssid" ]] && continue
			ap_id=${ap##*/}
			str=$(STR "$ap")
			b=$(BAND "$ap")
			sec=$(SEC "$ap")
			printf "%03d|%-5s %-35s %-6s %3d%% %5s\n" \
			"$str" "$ap_id" "$ssid" "$b" "$str" "$sec"
		done
	) | sort -t'|' -k1,1nr | head -30 | cut -d'|' -f2-
	} | rofi -dmenu -p "$title" -theme-str 'window {width: 555px; }'
} 

while true;
do
	R="$(WiFi_menu_p)"
case "$R" in
	"$A")
	UPD
	;;
	"$C")
	break
	;;
	*)
	ap_id=${R%% *}
	if [ "$ap_id" == "" ] || [ "$ap_id" == "󰖪" ]; then
		PLEN
	elif [[ $ap_id =~ ^[0-9]+$ ]]; then
		LINK "$ap_id"
	else
		printf "$IO"
	fi
	;;
esac
done
