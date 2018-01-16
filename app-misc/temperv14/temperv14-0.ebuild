# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs

DESCRIPTION="Read temperature values from TEMPer USB sensor."
HOMEPAGE="https://github.com/silverfisk/home-automation/tree/62a5bad3b15e690c12d4da50230cc540f3fcde07/temperv14"
SRC_URI="https://raw.githubusercontent.com/silverfisk/home-automation/62a5bad3b15e690c12d4da50230cc540f3fcde07/temperv14/temperv14.c -> temperv14.c"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE=""

DEPEND="virtual/libusb"
RDEPEND="${DEPEND}"

S="$WORKDIR"

src_unpack() {
	pushd "$DISTDIR" > /dev/null
	cp "$A" "$S"/ || die "Copying temperv14 source failed."	
	popd > /dev/null
}

src_compile() {
	"$(tc-getCC)" ${CFLAGS} ${LDFLAGS} -DUNIT_TEST -Wall -w -o temperv14 temperv14.c -lusb || die "Compiling failed."
}

src_install() {
	dobin temperv14
}
