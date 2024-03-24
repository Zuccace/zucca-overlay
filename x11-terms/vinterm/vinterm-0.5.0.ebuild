# Yeah blah blah GPL2
EAPI='8'

inherit desktop

DESCRIPTION="Vintage terminal - A terminal emulator that simulates old CRT. Like cool-retro-term, but with SDL instead of QT."
HOMEPAGE="https://github.com/andrenho/vinterm  https://code.google.com/archive/p/vinterm"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/vinterm/${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86"
SLOT="0"

MY_DEPS="media-libs/libsdl dev-libs/libconfig media-libs/libao"
BDEPEND="${MY_DEPS}"
RDEPEND="${MY_DEPS}"

set_emakeargs() {
	local includes="-I${EPREFIX}/usr/include/SDL/ -I${EPREFIX}/usr/include/ -I./"
	local PREFIX="${EPREFIX}/usr/"
	local extraflags="-DDEBUG=on -DPREFIX=\\\"${PREFIX}\\\" -DDATADIR=\\\"\${VINTERMPREFIX}\\\" -pedantic -Wall -std=c++0x -DVERSION=\\\"\${VERSION}\\\""

	eargs=(CFLAGS="${CFLAGS} ${includes} ${extraflags}"
		CXXFLAGS="${CXXFLAGS} ${includes} ${extraflags}"
		LDFLAGS="${LDFLAGS} ${includes} -L${EPREFIX}/usr/lib -L${EPREFIX}/usr/lib64 -lX11 -lutil -lSDL -lconfig++  ${extraflags}"
		VERSION="${PV}-zucca"
		PREFIX="${PREFIX}")
}

src_prepare() {
	sed -i 's/^#include <string>/#include <string>\n#include <cstdint>/' terminal/pty.h || die
	sed -i '/[[:space:]]\/usr\/share\//d' Makefile || die
	
	default
}

src_compile() {

	set_emakeargs
	local l
	emake "${eargs[@]}" options | while read l
	do
		elog "${l}"
	done
	
	emake "${eargs[@]}" all
}

src_install() {
	set_emakeargs
	emake DESTDIR="${D}" "${eargs[@]}" install
	local icon size
	find "${S}/icon" -type f \( -name '*.png' -or -name '*.svg' \) -print0 | while IFS=$'\0' read -d $'\0' icon
	do
		case "${icon##*.}" in
			png)
				size="${icon##*/icon_}"
				size="${size%.*}"
				newicon --size "${size}" "${icon}" "${PN}-${size}.png"
			;;
			svg)
				newicon "${icon}" "${PN}.svg"
			;;
		esac
	done
}
