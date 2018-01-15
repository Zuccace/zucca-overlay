# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Cryptocurrency for SCIENCE!"
HOMEPAGE="https://gridcoin.us"
MY_PN="Gridcoin-Research"
SRC_URI="https://github.com/${PN}/${MY_PN}/archive/${PV}.zip -> gridcoin-src-${PV}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie doc"

DEPEND="
	dev-libs/libzip
	net-libs/miniupnpc
	sys-libs/db:5.3[cxx]
	dev-libs/openssl
	dev-libs/boost
	>=sys-apps/gawk-4.1.0
"

RDEPEND="${DEPEND/>=sys-apps\/gawk-4.1.0/}"

S="${WORKDIR}/${MY_PN}-${PV}/src"

src_compile() {
	mkdir obj
	CXXFLAGS="${CXXFLAGS} -std=c++14 -I /usr/include/db5.3/"
	emake -f makefile.unix "NO_UPGRADE=1" $(use pie && echo -n "PIE=1")
}

src_install() {
	dobin gridcoinresearchd
}
