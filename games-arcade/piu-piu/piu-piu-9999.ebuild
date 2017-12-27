# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="An Old School horisontal scroller 'Shoot Them All' game in bash."
HOMEPAGE="https://github.com/vaniacer/piu-piu-SH"
EGIT_REPO_URI="${HOMEPAGE}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE=""

DEPEND=""
RDEPEND=">=app-shells/bash-4.2"

S="$WORKDIR/piu-piu-${PV}"

#src_unpack() {
#	cp "${DISTDIR}/piu-piu" "${S}/"
#}

src_install() {
	chown root:games "${S}/piu-piu"
	dobin "${S}/piu-piu"
}
