# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Project: Starfighter is a side-scrolling shoot 'em up space game"
HOMEPAGE="http://starfighter.nongnu.org"
DIR_V="$(grep -Eo '^[0-9]+\.[0-9]+' <<< "$PV")" # Didn't find any bash internal way to accomplish this.
SRC_URI=(http://{,download-}mirror.savannah.gnu.org/releases/${PN}/${DIR_V}/${P}-src.tar.gz)
LICENSE="GPL-3+"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""
DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-mixer"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}-src"

# (Literally) Cases for certain versions.
case "$PV" in
	1.5.1)
		# 1.5.1 tries put files to illegal locations.
		# 1.5.1 might then need manual src_install() or a patch.
		KEYWORDS="-*"
	;;
	9999)
		unset SRC_URI KEYWORDS
		inherit git-r3
		S="${S%-src}"
		EGIT_REPO_URI="git://git.savannah.gnu.org/${PN}.git"
	;;
esac
