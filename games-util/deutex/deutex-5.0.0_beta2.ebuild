# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="WAD file utility for Doom, Freedoom, Heretic, Hexen, and Strife"
HOMEPAGE="https://github.com/Doom-Utils/deutex"
SRC_URI="https://github.com/Doom-Utils/deutex/archive/v5.0.0-beta.2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE="png"

DEPEND="sys-devel/automake app-text/asciidoc"
RDEPEND="png? ( media-libs/libpng )"

export S="${WORKDIR}/deutex-5.0.0-beta.2"

src_prepare() {
	awk -v "date=$(date +%F)" '{if (/^AC_INIT\(/) sub("],"," Built on " date "],",$2); print}' configure.ac > configure.ac.new
	mv -f configure.ac{.new,}
	default
}

src_configure() {
	./bootstrap
	use png && ./configure --prefix="/usr" --with-libpng || ./configure --prefix="/usr" --without-libpng
}
