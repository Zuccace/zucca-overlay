# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Project: Starfighter is a side-scrolling shoot 'em up space game"
HOMEPAGE="http://starfighter.nongnu.org"
DIR_V="$(grep -Eo '^[0-9]+\.[0-9]+' <<< "$PV")"
SRC_URI="
	http://download.savannah.gnu.org/releases/starfighter/${DIR_V}/${P}-src.tar.gz
	http://download-mirror.savannah.gnu.org/releases/starfighter/${DIR_V}/${P}-src.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
case "$PV" in
	1.5.1)
		KEYWORDS="-amd64 -x86"
	;;
	*)
		KEYWORDS="~amd64 ~x86"
	;;
esac
IUSE=""

DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-mixer"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}-src"
