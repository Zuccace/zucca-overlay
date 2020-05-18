# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

DESCRIPTION="Apogee's scrolling space shooter"
HOMEPAGE="https://www.gog.com/game/stargunner"
RESTRICT="fetch strip"
SRC_URI="gog_stargunner_2.0.0.10.sh"
LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RDEPEND="games-emulation/dosbox"
S="$WORKDIR"

sgvardir="${ROOT%/}/var/games/${PN}"

pkg_nofetch() {
	einfo "You need to download the (free!) game from gog.com. Then save the *.sh file to your distdir."
	einfo "${HOMEPAGE}"
}

src_unpack() {
	# Find the byte offset where the zip file starts:
	((zip_offset=$(grep --byte-offset --only-matching --text "$(echo -ne "\x50\x4b\x03\x04")" "${DISTDIR%/}/$A" | head -n 1 | grep -Eo '^[0-9]+')+1))

	tail -c +"$zip_offset" "${DISTDIR%/}/$A" > archive.zip || die "Failed extracting zip from '${A}'"
	unzip archive.zip 'data/noarch/data/*' 'data/noarch/dosbox_stargun.conf' 'data/noarch/docs/*.pdf' 'data/noarch/support/icon.png'
	rm archive.zip &> /dev/null
}

src_prepare() {
	cat << EOF > stargunner
#!/bin/bash
sgroot="${ROOT%/}/usr/share/games/${PN}"
sgvardir="$sgvardir"
sgconfdir="\${XDG_CONFIG_HOME:-\${HOME%/}/.config}/${PN}"

if ! [[ -d "\$sgconfdir" ]]
then
	mkdir -p "\$sgconfdir"
	# Copy defaults... Needed?
	cp "\${sgroot}/STARGUN."{CFG,SAV} "\${sgconfdir}/"
	ln -s "\${sgroot}/"{STARGUN.{EXE,DLT},SETUP.EXE} "\$sgconfdir"/
	ln -s "\${sgvardir%/}/STARGUN.HI" "\$sgconfdir"/
fi

dbcbn='dosbox.conf'
for dosbox_conf in "\${sgconfdir}/\${dbcbn}" "${ROOT%/}/etc/${PN}/\${dbcbn}"
do
	[[ -r "\$dosbox_conf" ]] && break
done

: \${dosbox_conf:="\${sgroot}/\${dbcbn}"}

case "\${0##*-}" in
	setup)
		exe="SETUP.EXE"
	;;
	*)
		exe="STARGUN.EXE"
	;;
esac

(
	# Drop all wayland env vars.
	unset \$(env | awk '{ l = tolower(\$0); if (l !~ /sway/ && l ~ /wayl/) print substr(\$0,1,match(\$0,"=")-1)}')
	dosbox -conf "\$dosbox_conf" -conf <(cat <<- END
		[autoexec]
		mount C "\${sgconfdir}/"
		c:
		cls
		\$exe
		exit
		END
	) "\$exe" "\$@"
)
EOF

	# Patch dosbox config file here so that it really opens as fullscreen.
	gawk -i inplace '{if (/^\s*fullresolution=/) print "fullresolution=desktop"; else print}' data/noarch/dosbox_*.conf

	default
}

src_install() {
	insinto "/usr/share/games/${PN}"
	doins data/noarch/data/{STARGUN.{EXE,DLT,CFG,SAV},SETUP.EXE}

	insinto "/usr/lib/${PN}"
	newins data/noarch/dosbox_stargun.conf dosbox.conf

	insinto "/etc/${PN}"
	newins data/noarch/dosbox_stargun.conf dosbox.conf
	
	insinto "/var/games/${PN}"
	doins data/noarch/data/STARGUN.HI
	fowners -R root:gamestat "/var/games/${PN}"
	fperms 575 "/var/games/${PN}"
	fperms 464 "/var/games/${PN}"/*
		dobin "$PN"
	fowners root:gamestat "/usr/bin/${PN}"
	fperms g=xsr "/usr/bin/${PN}"
	fperms u-rwx "/usr/bin/${PN}"
	fperms o=rx "/usr/bin/${PN}"

	newicon data/noarch/support/icon.png "${PN}.png"
	make_desktop_entry "/usr/bin/${PN}" "Stargunner" "${PN}"
	make_desktop_entry "/usr/bin/${PN}-setup" "Stargunner setup" "${PN}"

	dodoc data/noarch/docs/*.pdf
	
	dosym ./"$PN" /usr/bin/"$PN"-setup
}
