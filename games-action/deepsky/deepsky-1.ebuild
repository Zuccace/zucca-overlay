# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="Prototype for a procedural planetary platforming adventure."
HOMEPAGE="https://cannonbreed.itch.io/deepsky"
SRC_URI="deepsky-demo-final.love"
	#fetch+https://img.itch.zone/aW1nLzIwNzQyNjYucG5n/original/kSXQtv.png -> ${PF}.png
GAMEFILE="${SRC_URI%% *}"
RESTRICT="mirror strip fetch"

LICENSE="Free-to-play"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="app-arch/unzip"
RDEPEND="	virtual/opengl
		games-engines/love
		dev-lua/LuaBitOp"

S="${DISTDIR%/}"

pkg_nofetch() {
	einfo "You need to download the game manually fron ${HOMEPAGE} and place the '${GAMEFILE}' into '${PORTAGE_ACTUAL_DISTDIR}'"
}

src_compile() {
	unzip -p deepsky-demo-final.love assets/window_icon.png > "${T%/}/${PN}.png"
}

src_install() {
	insinto /opt

	doins "${GAMEFILE}"
	doicon "${T%/}/${PN}.png"
	newbin <(
		cat <<- END
			#!/bin/sh
			# Simple launcher for ${PN}.

			exec ${EROOT}/usr/bin/love ${EROOT}/opt/${GAMEFILE}
		END
	) "$PN"
	make_desktop_entry "/usr/bin/${PN}" "${PN^}" "${PN}"
	
	
}
