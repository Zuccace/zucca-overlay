# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="WAD file utility for Doom, Freedoom, Heretic, Hexen, and Strife."
HOMEPAGE="https://github.com/Doom-Utils/deutex"
EGIT_REPO_URI="${HOMEPAGE}.git"
EGIT_COMMIT="89a523654333c751b6f59c2b38c1529e1ae49363"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="png"

RDEPEND="png? ( media-libs/libpng:0/16 )"
DEPEND="sys-devel/automake app-text/asciidoc ${RDEPEND}"

src_prepare() {
	awk -v "gitvers=${PVR}-git Built on $(date +%F)" '{if (/^AC_INIT\(/) $2 = "[" gitvers "],"; print}' configure.ac > configure.ac.new
	mv -f configure.ac{.new,}
	default
}

src_configure() {
	./bootstrap
	use png && ./configure --prefix="/usr" --with-libpng || ./configure --prefix="/usr" --without-libpng
}
