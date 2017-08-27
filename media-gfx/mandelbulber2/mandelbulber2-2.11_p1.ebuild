# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils #cmake-utils

DESCRIPTION="3D fractal explorer"
HOMEPAGE="http://mandelbulber.com"
BASE_SRC="https://github.com/buddhi1980/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 -x86"
IUSE="examples"
[ "${PV%%_*}" = "2.12" ] && IUSE="${IUSE} opencl" && OCL_DEP="opencl? ( dev-libs/opencl-clhpp )"

MY_PV="${PV/_p/-}"
MY_PV="${MY_PV/_alpha/-alpha}"
S="${WORKDIR}/${PN}-${MY_PV}/${PN}"

case "$PVR" in
	9999*)
		inherit git-r3
		EGIT_URI="${BASE_SRC}.git"
	;;
	2.11_p1)
		KEYWORDS="~amd64 ~x86"
	;;
esac
: ${SRC_URI:="${BASE_SRC}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"}

DEPEND="
	virtual/jpeg:62
	media-libs/libpng:0/16
	>=dev-qt/qtcore-5.0
	dev-qt/qtmultimedia:5
	dev-qt/designer:5
	dev-qt/qttest:5
	sci-libs/gsl
	${OCL_DEP}

"
RDEPEND="${DEPEND}
	sys-cluster/openmpi
"

#src_prepare() { die on purpose; }

src_configure() {
	if [ -d "Release" ]
	then
		export RELDIR="Release"
		pushd "$RELDIR" || die "Couldn't cd to $RELDIR"
		/usr/lib64/qt5/bin/qmake "${PN%2}.pro" 2> "${T}/qmake_error.log" || die "$(cat "${T}/qmake_error.log")"
	elif [ -d "qmake" ]
	then
		export RELDIR="qmake"
		pushd "$RELDIR" || die "Couldn't cd to $RELDIR"
		/usr/lib64/qt5/bin/qmake "${PN%2}$(use opencl && echo -n '-opencl').pro" 2> "${T}/qmake_error.log" || die "$(cat "${T}/qmake_error.log")"
	fi
	popd

	# workaround for buggy dev-libs/opencl-clhpp
	if use opencl
	then
		find src/ -type f -name '*.hpp' -execdir sh -c 'grep -qE "^\s*#include +<CL/" {} && gawk -i inplace "sub(/^\s*#include <CL\//,\"#include </usr/CL/\")" {}' \;
	fi
}

src_compile() {
	cd "$RELDIR" || die "Couldn't cd to $RELDIR"
	default
}

src_install() {
	dodoc "deploy/share/${PN}/doc/"*
	insinto "/usr/share/${PN}/doc"
	PDFDOC="${PN%2}"
	PDFDOC="${PDFDOC^}_Manual.pdf"
	ln -s "${ROOT%/}/usr/share/doc/${P}/${PDFDOC}" "$PDFDOC"
	doins "$PDFDOC"

	domenu "deploy/linux/${PN}.desktop"
	doicon -s 256 "deploy/share/${PN}/icons/${PN%2}.png"

	for d in data qt_data language \
	"deploy/share/${PN}/"{icons,textures,toolbar} \
	"$(use examples && echo -n "deploy/share/${PN}/examples")"
	do
		test -d "$d" || continue
		insinto "/usr/share/${PN}/${d##*/}"
		doins "${d}/"*
	done

	for d in formula "$(use opencl && echo -n "opencl")"
	do
		dodir "/usr/share/${PN}/${d}"
		cp -a "${d}"/* "${D}/usr/share/${PN}/${d}/" || die "Installing ${d} -directory failed."
	done

	dobin "${RELDIR}/mandelbulber2"
}
