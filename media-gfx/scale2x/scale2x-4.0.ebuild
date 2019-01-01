# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="Real-time scaler of small bitmaps without blurring"
HOMEPAGE="http://www.scale2x.it"
SRC_URI="https://github.com/amadvance/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 -x86 -arm64 -arm"
IUSE=""

DEPEND="media-libs/libpng:0"
RDEPEND="${DEPEND}"

src_configure() {
	#eautoreconf
	./autogen.sh > /dev/null || die '.autogen.sh failed.'
	eautomake
	./configure || die ".configure failed."
}

src_install() {
	emake install prefix="${ED}/usr"
}
