# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A map editor for the classic DOOM games, and others alike such as Heretic and Hexen."
HOMEPAGE="http://eureka-editor.sourceforge.net"

# I never got the mirror://sourceforge to work. :( However the URL below will take any mirror.
SRC_URI="https://downloads.sourceforge.net/project/eureka-editor/Eureka/1.21/eureka-121-source.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc ~ppc64 ~arm ~arm64"
IUSE="xinerama"

RDEPEND="
	xinerama? ( x11-libs/libXinerama )
	sys-libs/zlib
	media-libs/libpng:0/16
	virtual/jpeg
	x11-misc/xdg-utils
	x11-libs/fltk
	x11-libs/libXft"

DEPEND="${RDEPEND} sys-devel/make"

S="${S}-source"

src_configure() {
	awk -v "prefix=${D}/usr" '{if ($1 ~ "^PREFIX=") {print "PREFIX=" prefix; next} else if ($1 ~ /^xdg-/) next; else if ($1 ~ /^[a-z]+:$/ && seen != "1") {printf "CFLAGS  += -I/usr/include/fltk\nCXXFLAGS  += -I/usr/include/fltk\nLDFLAGS += -L/usr/lib/fltk/\n\n"; seen="1"} print}' Makefile > Makefile.new \
	&& mv -f Makefile.new Makefile
}

src_install() {
	usr="${D}/usr"
	mkdir -p "${usr}/share/eureka"
	mkdir -p "${usr}/bin"
	emake INSTALL_DIR="${usr}/share/eureka" install
}
