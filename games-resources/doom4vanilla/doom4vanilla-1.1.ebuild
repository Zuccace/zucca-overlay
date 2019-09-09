# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Doom 2016 the Way 1993 Did It"
HOMEPAGE="https://www.doomworld.com/forum/topic/108725-doom-4-vanilla-v11-ms-dos-edition/"
LICENSE="freedist"
SLOT="$PV"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc ~ppc64"

BDEPEND="
app-arch/unzip"

SLOTNAME="$PV"

SRC_URI="https://www.dropbox.com/s/6171549kz36bfkx/D4V_v${PV}.zip?dl=1 -> ${P}.zip"

S="$WORKDIR"

src_compile() {
	true
}

src_install() {
	find . -type f -regextype egrep -iregex '^.+/[^/]+\.(dll|exe|bat)' -delete
	rm 'put DOOM2.WAD here.txt'
	insinto "usr/share/games/doom/doom4vanilla/${SLOTNAME}"
	doins -r *
}

pkg_postinst() {
	games_pkg_postinst
}
