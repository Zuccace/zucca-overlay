# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Project: Starfighter is a side-scrolling shoot 'em up space game"
HOMEPAGE="http://starfighter.nongnu.org"
SRC_URI="
	http://download.savannah.gnu.org/releases/starfighter/${PV}/${P}-src.tar.gz
	http://download-mirror.savannah.gnu.org/releases/starfighter/${PV}/${P}-src.tar.gz
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-mixer"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}-src"
