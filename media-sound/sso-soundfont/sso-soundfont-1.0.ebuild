# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Sonatina Symphonic Orchestra soundfont"
HOMEPAGE="
	http://sso.mattiaswestlund.net/
	https://musescore.org/en/node/20378
"
SRC_URI="ftp://ftp.osuosl.org/pub/musescore/soundfont/Sonatina_Symphonic_Orchestra_SF2.zip"

LICENSE="CC-Sampling-Plus-1.0"
SLOT="0"
KEYWORDS="~*"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""
S="${WORKDIR}"

src_install() {
	dodoc README
	insinto /usr/share/sounds/sf2/
	doins *.sf2
}
