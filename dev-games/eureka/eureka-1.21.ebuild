# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils xdg

DESCRIPTION="A map editor for the classic DOOM games, and others such as Heretic and Hexen."
HOMEPAGE="http://eureka-editor.sourceforge.net"

# Versions after 1.07 don't have dot in version string in their source package filename.
case "${PV}" in
	0.*|1.07)
		PKGV="${PV}"
	;;
	*)
		PKGV="${PV//./}"
	;;
esac
SRC_URI="https://downloads.sourceforge.net/project/eureka-editor/${PN^}/${PV}/${PN}-${PKGV}-source.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc ~ppc64 ~arm"
IUSE="xinerama"

RDEPEND="
	xinerama? ( x11-libs/libXinerama )
	sys-libs/zlib
	media-libs/libpng:0/16
	virtual/jpeg:*
	x11-misc/xdg-utils
	x11-libs/fltk
	x11-libs/libXft"

DEPEND="${RDEPEND} sys-devel/make
>=sys-apps/gawk-4.1.0"

src_unpack() {
	default
	[ ! -d "$S" ] && S="${S}-source"
}

src_prepare() {
	einfo "Patching Makefile on-the-fly..."
	# Modify PREFIX, drop lines using xdg and adjust few compiler flags.
	gawk -i inplace -v "prefix=${D}/usr" -v "libdir=$(get_libdir)" '{if ($1 ~ "^(INSTALL_)?PREFIX=") sub(/=.+$/,"=" prefix); else if ($1 ~ /^xdg-/) next; else if ($1 ~ /^[a-z]+:$/ && seen != "1") {printf "CFLAGS  += -I/usr/include/fltk\nCXXFLAGS  += -I/usr/include/fltk\nLDFLAGS += -L/usr/" libdir "/fltk/\n\n"; seen="1"} print}' Makefile || die "gawk patching failed."
	# Remove owner settings from install -lines.
	gawk -i inplace '{if ($1 == "install") gsub(/[[:space:]]-o[[:space:]][^[:space:]]+/,""); print}' Makefile || die "gawk patching failed."
	einfo "Makefile patching done."
	default
}

src_install() {

	domenu misc/eureka.desktop
	doicon -s 32 misc/eureka.xpm

	usr="${D}/usr"
	mkdir -p "${usr}/share/eureka"
	mkdir -p "${usr}/bin"
	emake INSTALL_DIR="${usr}/share/eureka" install
}
