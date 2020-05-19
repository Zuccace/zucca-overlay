# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop gog

DESCRIPTION="A remake of 'Wonder Boy III - The Dragon's Trap'"
HOMEPAGE="http://www.thedragonstrap.com/"
RESTRICT="fetch strip"
SRC_URI="wonder_boy_the_dragon_s_trap_en_1_03f_02_20817.sh"

LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="-system-libsdl2"

DEPEND=""
RDEPEND="system-libsdl2? ( media-libs/libsdl2 )"
BDEPEND=""

S="$WORKDIR"
MY_PN="wb-tdt"

pkg_nofetch() {
	einfo "You need to buy the game from gog.com. Then save the *.sh file to your distdir."
	einfo "https://www.gog.com/game/wonder_boy_the_dragons_trap"
}

src_configure() {

	pushd "${S%/}/data/noarch/game" &> /dev/null || die

	if use amd64
	then
		rm -fr x86 || die
		mv x86_64/{wb.x86_64,WonderBoy.bin} || die
		mv {x86_64,bin} || die
	else
		rm -rf x86_64 || die
		mv x86/{wb.x86,WonderBoy.bin} || die
		mv {x86,bin} || die
	fi

	# Cli laucher creation. 
	cat <<- EOF > ./WonderBoy
		#!/bin/sh
		cd "\$(dirname "\$(readlink -f "\$0")")"
		if [ "\${0##*WonderBoy-}" == "bundled-sdl" ]
		then
			export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:./bin/"
			echo "Using bundled libsdl2."
		else
			echo "Using system provided libsdl2."
		fi
		./bin/WonderBoy.bin "\$@"

	EOF

	# Creating "bundled-sdl" synlink under /opt too.
	# Not really needed but it's there for the curious ones.
	ln -s ./WonderBoy{,-bundled-sdl}

	popd &> /dev/null || die
}

src_compile() {
	true
}

src_install() {
	newicon data/noarch/game/WonderBoy.png "${MY_PN}.png"
	make_desktop_entry "/opt/${MY_PN}/WonderBoy$(use system-libsdl2 || echo -n "-bundled-sdl")" "Wonder Boy: The Dragon's Trap" "${MY_PN}"

	insinto "/opt/${MY_PN}"
	doins -r data/noarch/game/{bin{,_pc},WonderBoy{,-bundled-sdl,.png},gamecontrollerdb.txt}
	chmod +x "${D%/}"/opt/${MY_PN}/{bin/WonderBoy.bin,WonderBoy} || die

	dosym "/opt/${MY_PN}/WonderBoy" /usr/games/bin/WonderBoy
	dosym "/opt/${MY_PN}/WonderBoy" /usr/games/bin/WonderBoy-bundled-sdl
}

pkg_postinst() {
	if use system-libsdl2
	then
		cat <<- EOF | fold -s | while read message; do einfo "$message"; done

			== NOTE when using USE=system-libsdl2 ==
			When using system provided libsdl2 audio might get distorted.
			First run the game. If the audio is distorted then try to fix the problem by modifying the size of audio buffer in 'Settings.cfg' -file.
			It's usually located in
			"~/.config/Lizardcube/The Dragon's Trap/Settings.cfg".
			Note: Preserve those quotes when editing from shell. ;)

			The following audio configuration has been working for the maintainer of this ebuild:
			EOF
			cat <<- EOF | awk '{sub(/^\s+/,"\t"); print}'
				-- AUDIO
				AudioSamplingRate = 48000,
				AudioBufferSize = 5000,
				AudioMusicSpeed = 60,
				AudioClipRoundoff = true,
				AudioClipScaler = 1,

			EOF
	fi
}

