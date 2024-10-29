#!/bin/sh

is_caged() {
	[ "$XDG_CURRENT_DESKTOP" = 'cage' ] && pgrep -u "$(whoami)" cage > /dev/null 2>&1
}

to() {
	nice -n 18 timeout --foreground --signal=TERM --kill-after=6m 5m "$@"
}

rint() {
	shuf -i ${1}-${2} -n 1
}

Xwayland() {
	if ! pgrep -u player Xwayland > /dev/null  2>&1
	then
		command Xwayland "$@"
	fi
}

rootfulX() {
	nice -n 18 Xwayland :11 -br -geometry 1920x1080 -fullscreen "$@" &
	export DISPLAY=':11'
	sleep 1
}

fastfetch() {
	command fastfetch --physicaldisk-temp --cpu-temp --gpu-temp --weather-location 'Utti' \
		--structure "Title:Separator:Host:CPU:GPU:Bios:Display:PhysicalDisk:Memory:Swap:OS:Kernel:Uptime:Processes:Packages:Terminal:LocalIp:Wifi:Locale"
}

ntp_sources() {
	chronyc -cn sources \
	| sort -n -t , -k 10 \
	| head -n "${1:-10}" \
	| awk -v FS=',' -v OFS=' ' '{
		domain=""
		"dig -x " $3 " +short" | getline domain
		close("dig -x " $3 " +short")
		if (domain != "") $3 = substr(domain,1,length(domain)-1)
		print $3 "\n" $2 " " $7/60 "m " $10*1000 "ms"
	}'
}

randomize_tv_adj() {
	local color="$(rint 10 100)"
	local brightness="$(rint 1 40)"
	local contrast="$(rint 5 100)"
	local tint=$(rint 0 175)
	let tint="${tv_tint}"-"$(rint 0 175)"

	printf '%s' "--tv-color ${color} --tv-contrast ${contrast} --tv-tint ${tint} --tv-brightness ${brightness} " | tee "${TMPDIR}/random_tv.log"
}

player_terminal() {
	#/usr/lib64/misc/xscreensaver/phosphor --window \
	#	--ticks 1 --scale 2 --delay 0 --program "${0} terminal"
	# /usr/lib64/misc/xscreensaver/apple2 --window \
	#	--tv-color 128 --tv-contrast 92 --tv-tint 32 --tv-brightness 10 \
	#	--text --fast --program "${0} terminal"
	#cool-retro-term -e ${0} terminal

	#ln -s "$0" "${TMPDIR}/sh"
	#export PATH="${TMPDIR}:${PATH}"

	#echo "$0" > "${TMPDIR}/shell.val"
	#env SHELL="$0" vinterm --no-audio --scale=4
	cool-retro-term --fullscreen --profile 'Monochrome Green' -e "$0" terminal
	exec "$0" caged
}

screensaver() {
	export XENVIRONMENT="/etc/player_X.env"
	rootfulX
	#spid="$$"
	#xwpid="$!"

	swayidle timeout 1 "beep -f 25 -l 100" resume "killall timeout" &

	while [ "${es:-124}" -eq '124' ]
	do
		sleep 1
		
		if pgrep -u root -x emerge > /dev/null  2>&1
		then
			#killall Xwayland
			#nice -n 18 timeout --foreground --signal=TERM --kill-after=5h 4h \
				cool-retro-term --fullscreen -e "$0" emerge-demo
		else
			case "$(rint 1 4)" in
				1)
					to /usr/lib64/misc/xscreensaver/xmatrix --root \
						--delay 75000 --density 35 --mode trace --phone "1337666" \
						--mode pipe --program "$0 demo-terminal nonoise"
				;;
				2)	
					to /usr/lib64/misc/xscreensaver/xanalogtv --root \
						$(randomize_tv_adj) \
						--image /etc/player_images/green_hill_zone.png
				;;
				3)
					to /usr/lib64/misc/xscreensaver/apple2 --root \
						$(randomize_tv_adj) \
						--program "pfetch"
				;;
				4)
					to /usr/lib64/misc/xscreensaver/apple2 --root \
						$(randomize_tv_adj) \
						--text --program "$0 demo-terminal"

				;;
			esac
		fi
		es="$?"
	done

	# TODO: Do not brute force
	# .. also not needed, we have trap
	#killall Xwayland
	killall swayidle
}

case "$1" in
	caged)
		if is_caged
		then
			"$0" screensaver
			player_terminal
		else
			exec "$0"
		fi
	;;
	screensaver)
		screensaver
	;;
	terminal)
		clear
		source /etc/profile
		fastfetch
		ip neigh
		nmcli --fields 'IN-USE,SSID,BSSID,SIGNAL,BARS' dev wifi list --rescan no
		exec bash -il
	;;
	demo-terminal)
		if ! pgrep -u root -x emerge > /dev/null  2>&1
		then
			fastfetch --pipe | /usr/local/bin/boxify.sh 40 "${2}"
			{
				nmcli --fields 'IN-USE,SSID,BSSID,SIGNAL' dev wifi list --rescan no | awk '{$2=substr($2,1,10); gsub(/:/,"",$3); print $1 "\t" $2 "\t" tolower($3) "\t" $4}' | column -s $'\t' -t
				printf '%36s\n' | tr " " "="
				ip neigh | awk '{gsub(/:/,"",$5); if ($6 == "REACHABLE") $6 = "ACTIVE"; print $1,tolower($5),$6}' | column -t
				printf '%36s\n' | tr " " "="
			} | /usr/local/bin/boxify.sh 40 "${2}"
			ntp_sources 5 | /usr/local/bin/boxify.sh 40 "${2}"
			uptime | /usr/local/bin/boxify.sh 20 "${2}"
			
		else
			# TODO?
			qlop -m | tail -n 5 | sed 's/ >>> /\n/' | /usr/local/bin/boxify.sh 30
		fi
	;;
	emerge-demo)
		swayidle timeout 1 "beep -f 2500 -l 100" resume "killall cool-retro-term" &
			fastfetch
		while :
		do
			sleep 2s
			qlop -vmHt | tail -n 20 | /usr/local/bin/boxify.sh 80 | pv --quiet --rate-limit 600
			sleep 2s
			fastfetch | /usr/local/bin/boxify.sh 80 | pv --quiet --rate-limit 600
			sleep 2s
			ntp_sources 30 | /usr/local/bin/boxify.sh 50 \
			| pv --quiet --rate-limit 600

		done
	;;
	text)
		cat <<- ENDTEXT | paste -sd ' ' 
			Most common random number is 37.
			You recognize suport god from the fact that he can aid other in Gentoo related problems too.
			Are you reading this?
		ENDTEXT
	;;
	*)
		if grep -Eq '(^|\s)(no-fancy)($|\s)' /proc/cmdline
		then
			while :
			do
				cmatrix -u 6 -b -s
				clear
				exec bash -il
			done
		elif ! is_caged 
		then
			if grep -Eq '(^|\s)(pause|shell|debug)($|\s)' /proc/cmdline
			then
				fastfetch

				echo "Press any key to start..."
				read
			else
                		chvt 1
				fastfetch
				sleep 1
                		#timeout --kill-after=15 3 cmatrix -bsu 6
			fi
		
			exec startwayland --pipewire cage -m -s -- "$0" caged > ${TMPDIR}/cage.log 2>&1
		else
			exec "$0" terminal
		fi
	;;
esac

# We should never end up here...
