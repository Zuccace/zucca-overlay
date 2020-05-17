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
#IUSE="-system-libsdl2"

#DEPEND=""
RDEPEND="games-emulation/dosbox"
#BDEPEND="app-misc/detox"

S="$WORKDIR"

pkg_nofetch() {
	einfo "You need to download the (free!) game from gog.com. Then save the *.sh file to your distdir."
	einfo "${HOMEPAGE}"
}

src_unpack() {
	# Extract files related to installing:
	# Left here if we'd need them some day...
	#awk '{if (p == 1) print; else if ($0 == "eval $finish; exit $res") p = 1}' "${DISTDIR%/}/$A" | tar -xzf -

	# Find the byte offset where the zip file starts:
	((zip_offset=$(grep --byte-offset --only-matching --text "$(echo -ne "\x50\x4b\x03\x04")" "${DISTDIR%/}/$A" | head -n 1 | grep -Eo '^[0-9]+')+1))

	tail -c +"$zip_offset" "${DISTDIR%/}/$A" > archive.zip || die "Failed extracting zip from '${A}'"
	#unpack "${S%/}/archive.zip"
	unzip archive.zip 'data/noarch/data/*' 'data/noarch/dosbox_stargun.conf' 'data/noarch/docs/*.pdf' 'data/noarch/support/icon.png'
	rm archive.zip &> /dev/null
}

src_prepare() {
	cat << EOF > stargunner
#!/bin/bash
sgroot="${ROOT%/}/usr/share/games/${PN}"
sgconfdir="\${XDG_CONFIG_HOME:-\${HOME%/}/.config}/${PN}"

if ! [[ -d "\$sgconfdir" ]]
then
	mkdir -p "\$sgconfdir"
	# Copy defaults... Needed?
	cp "\${sgroot}/STARGUN."{CFG,HI,SAV} "\${sgconfdir}/"
	ln -s "\${sgroot}/"{STARGUN.{EXE,DLT},SETUP.EXE} "\$sgconfdir"/
fi

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
	dosbox -conf "\${sgroot}/dosbox_stargun.conf" -conf <(cat <<- END
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

	default
}

src_install() {
	insinto "/usr/share/games/${PN}"
	doins -r data/noarch/data/* data/noarch/dosbox_*.conf

	exeinto /usr/games/bin
	doexe "$PN"

	newicon data/noarch/support/icon.png "${PN}.png"
	make_desktop_entry "/usr/games/bin/${PN}" "Stargunner" "${PN}"
	make_desktop_entry "/usr/games/bin/${PN}-setup" "Stargunner setup" "${PN}"

#	detox -v -f <(cat <<-EOF
#	sequence default {
#		utf_8;
#		safe;
#	};
#	EOF
#	) data/noarch/docs/*.pdf
	dodoc data/noarch/docs/*.pdf
	
	dosym /usr/games/bin/"$PN" /usr/games/bin/"$PN"-setup
}
