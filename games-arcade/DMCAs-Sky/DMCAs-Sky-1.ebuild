# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="DMCA's Sky - Help Spaceman Finn search for Princess Mango"
HOMEPAGE="https://asmb.itch.io/dmcas-sky"
PKG_BASE="DMCAsSky"
SRC_URI="${PKG_BASE}-linux.zip"

RESTRICT="mirror fetch strip"

LICENSE="ASMB_Free-to-play"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="virtual/opengl"

S="${SRC_URI%.zip}"
S="${WORKDIR%/}/${S##*/}"

src_install() {
	BINNAME="${PKG_BASE}.$(uname -m)"
	OPTDIR="/opt/${PN}/"
	exeinto "$OPTDIR"
	insinto "$OPTDIR"
	into "/usr/games/"
	doexe "$BINNAME"
	doins -r "${PKG_BASE}_Data"
	#dosym "${EPRFIX%/}${OPTDIR}${BINNAME}" /usr/games/bin/dmcas-sky
	newbin <(
		echo '#!/bin/sh'
		echo "cd \"${OPTDIR}\" || exit \"\$?\""
		echo "./${BINNAME}" '"$@"'
		echo 'ESTATUS="$?"'
		echo 'exit "$ESTATUS"'
	) dmcas-sky

	dodoc readme.txt

	#die on purpose

}
