# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A pretty system information tool written in POSIX sh"
HOMEPAGE="https://github.com/dylanaraps/pfetch"
SRC_URI="	https://raw.githubusercontent.com/dylanaraps/pfetch/${PV}/pfetch -> ${PF}.sh
		https://raw.githubusercontent.com/dylanaraps/pfetch/0.6.0/README.md -> README-${PF}.md"
RESTRiCT="mirror"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
S="${WORKDIR}"

src_unpack() { true; }

src_install() {
	newbin "${DISTDIR}/${PF}.sh" "${PN}"
	newdoc "${DISTDIR}/README-${PF}.md" "README_${PN}.md"
}
