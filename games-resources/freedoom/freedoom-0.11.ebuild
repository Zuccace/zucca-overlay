# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Freedoom - Open Source Doom resources"
HOMEPAGE="https://freedoom.github.io"
SRC_URI="https://github.com/freedoom/freedoom/releases/download/v${PV}/freedoom-${PV}.zip
	https://github.com/freedoom/freedoom/releases/download/v${PV}/freedm-${PV}.zip"

LICENSE="BSD"
SLOT="$PV"
KEYWORDS="~amd64 ~x86 ~arm ~aarch64"
IUSE=""

DEPEND="app-arch/unzip"

S=${WORKDIR}

src_install() {
	insinto "usr/share/games/doom/freedoom/${PV}"
	doins */*.wad
	DOCS="${P}/CREDITS ${P}/COPYING"
	HTML_DOCS="${P}/README.html"
        einstalldocs
}

pkg_postinst() {
	games_pkg_postinst
	elog "A Doom engine is required to play the wad"
	elog "but games-fps/doomsday doesn't count since it doesn't"
	elog "have the necessary features."
	echo
	ewarn "To play freedoom with Doom engines which do not support"
	ewarn "subdirectories, create symlinks by running the following:"
	ewarn "(Be careful of overwriting existing wads.)"
	ewarn
	ewarn "   ln -s -t ${GAMES_DATADIR}/doom/ ${GAMES_DATADIR}/doom/freedoom/${PV}/*.wad"
	ewarn
}
