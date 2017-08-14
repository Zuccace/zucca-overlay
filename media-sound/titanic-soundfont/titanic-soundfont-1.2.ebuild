# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A high quality MIDI soundfont by Luke Sena."
HOMEPAGE="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=soundfont-titanic&id=ad732b75ca6d1519335b408f1caf8400eab90f2f"
SF="titanic-${PV}.sf2"
LIC="${P}.LICENSE"
SRC_URI="
	https://www.dropbox.com/s/g0yxy0326jgar34/titanic.sf2 -> ${SF}
	https://aur.archlinux.org/cgit/aur.git/plain/LICENSE?h=soundfont-titanic&id=ad732b75ca6d1519335b408f1caf8400eab90f2f -> ${LIC}
"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~*"
IUSE=""

DEPEND=""
RDEPEND=""
S="${WORKDIR}"

src_unpack() {
	AA=($A)
	pushd "$DISTDIR" || die
	cp "${AA[@]}" "${S}/" || die
	popd || die
	mv *.LICENSE LICENSE || die
}

src_install() {
	dodoc LICENSE
	insinto /usr/share/sounds/sf2/
	doins *.sf2
}
