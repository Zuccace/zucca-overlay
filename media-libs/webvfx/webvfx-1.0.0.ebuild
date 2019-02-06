# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils

DESCRIPTION="Video effects library that uses WebKit HTML or Qt QML"
GH_USER="mltframework"
GH_REPO="${PN}"
HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"
SRC_URI="${HOMEPAGE}/releases/download/${PV}/${PN}-${PV}.txz -> ${P}.txz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtwebengine
	dev-qt/qt3d[qml]
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user
	local MLT_INCLUDE_DIR="${D%/}/usr/$(get_libdir)/mlt"
	einfo "$MLT_INCLUDE_DIR"
	gawk -i inplace -v "mlt_incdir=${MLT_INCLUDE_DIR}" '{if (/^target.path =/) $0 = "target.path = " mlt_incdir; print}' mlt/mlt.pro
}

src_configure() {
	eqmake5 PREFIX="${D%/}/usr" # MLT_PREFIX="${D%/}/usr"
}
