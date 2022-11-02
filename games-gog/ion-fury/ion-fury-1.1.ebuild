# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop gog

DESCRIPTION="Cyberpunk themed fps based on the Ken Silverman's Build engine."
HOMEPAGE="https://www.gog.com/en/game/ion_fury"
SRC_URI="${PN//-/_}_${PV//./_}_41247.sh"
# ion_fury_1_1_41247.sh
LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="fetch strip bindist"
S="$WORKDIR"

RDEPEND="
	media-libs/flac-compat
	media-libs/libsdl2"

pkg_nofetch() {
	einfo "You need to buy and download Ion Fury from gog.com."
	einfo "Then save the ${SRC_URI} file to your distdir."
	einfo "${HOMEPAGE}"
}

# We'll go all in and include everything from GSD.
UNZIP_LIST=("${GSD%/}/*" 'data/noarch/support/icon.png')

src_prepare() {
	rm -v "${GSD%/}/"*.exe
	eapply_user
}

src_configure() {
	cat > "${T%/}/${PN}" <<- ENDLAUNCHER
#!/bin/sh

furyhome="\${HOME%/}/.config/fury"

if [ ! -d "\$furyhome" ]
then
	if ! mkdir -p "\$furyhome"
	then
		exit 1
	fi
fi

cd "\$furyhome"

exec "/opt/${PN}/fury_nodrm.bin -j '' "\$@"
echo "Something went terribly wrong." 1>&2
ENDLAUNCHER
}

src_install() {
	exeinto "/opt/${PN}"
	doexe "${GSD%/}/fury_nodrm.bin"
	rm "${GSD%/}/fury_nodrm.bin"
	insinto "/opt/${PN}"
	doins data/noarch/game/*
	dobin "${T%/}/${PN}"

	newicon data/noarch/support/icon.png "${PN}.png"
	make_desktop_entry "$PN" 'Ion Fury' "$PN" Game
}
