# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="DMCA's Sky - Help Spaceman Finn search for Princess Mango"
HOMEPAGE="https://asmb.itch.io/dmcas-sky"
PKG_BASE="DMCAsSky"
ARCHIVE_NAME="${PKG_BASE}-linux.zip"
ICON="dmcas-sky.png"
SRC_URI="${ARCHIVE_NAME}
https://img.itch.zone/aW1hZ2UvODM2MzgvMzk0MjYyLnBuZw==/315x250%23c/ipWepf.png -> $ICON"

RESTRICT="mirror strip"

LICENSE="ASMB_Free-to-play"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
	+extras
"

DEPEND="app-arch/unzip"
RDEPEND="virtual/opengl
	extras? ( app-shells/bash )
	extras? ( >=sys-apps/gawk-4.1.3 )"

S="${ARCHIVE_NAME%.zip}"
S="${WORKDIR%/}/${S##*/}"

pkg_nofetch() {
	einfo "You need to download the game manually fron ${HOMEPAGE} and place the '${ARCHIVE_NAME}' into '${DISTDIR}'"
}

src_install() {
	BINNAME="${PKG_BASE}.$(uname -m)"
	OPTDIR="/opt/${PN}/"

	exeinto "$OPTDIR"
	insinto "$OPTDIR"
	into "/usr/games/"

	doexe "$BINNAME"
	doins -r "${PKG_BASE}_Data"
	use extras && newbin "$FILESDIR/run-dmcas-sky.sh" dmcas-sky || \
	newbin <(
		echo '#!/bin/sh'
		echo "cd \"${OPTDIR}\" || exit \"\$?\""
		echo "./${BINNAME}" '"$@"'
		echo 'exit "$?"'
	) dmcas-sky
	dodoc readme.txt
	doicon "${DISTDIR%/}/${ICON}"
	make_desktop_entry dmcas-sky "DMCA's Sky" "$ICON"
}
