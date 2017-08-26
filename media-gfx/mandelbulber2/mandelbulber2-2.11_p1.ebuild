# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="3D fractal explorer"
HOMEPAGE="http://mandelbulber.com"
BASE_SRC="https://github.com/buddhi1980/${PN}"
MY_PV="${PV/_p/-}"
case "$PVR" in
	9999*)
		inherit git-r3
		EGIT_URI="${BASE_SRC}.git"
	;;
	*)
		# Offical release.
		S="${WORKDIR}/${PN}-${MY_PV}"
	;;
esac
: ${SRC_URI:="${BASE_SRC}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 -x86"
IUSE="examples"

DEPEND="
	virtual/jpeg
	media-libs/libpng:0/16
	>=dev-qt/qtcore-5.0
	dev-qt/qtmultimedia:5
	dev-qt/designer:5
	dev-qt/qttest:5
	sci-libs/gsl

"
RDEPEND="${DEPEND}
	sys-cluster/openmpi
"

src_configure() {
	cd "${PN}/Release/"
	/usr/lib64/qt5/bin/qmake "${PN%2}.pro" 2> "${T}/qmake_error.log" || die "$(cat "${T}/qmake_error.log")"
}

src_compile() {
	cd "./${PN}/Release/"
	default
}

src_install() {
	dodoc "${PN}/deploy/share/${PN}/doc/"*
	domenu "${PN}/deploy/linux/${PN}.desktop"
	if use examples
	then
		insinto "/usr/share/${PN}/examples"
		einstall "${PN}/deploy/share/${PN}/examples/"*
	fi
	dobin "${PN}/Release/mandelbulber2"
}
