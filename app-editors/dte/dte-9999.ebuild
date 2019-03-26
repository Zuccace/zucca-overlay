# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A small and easy to use console text editor"
GL_USER="craigbarnes"
GL_REPO="${PN}"
HOMEPAGE="https://${GL_USER}.gitlab.io/${PN}/"
LICENSE="GPL-3"
SLOT="0"

case "$PV" in
	9999*)
		inherit git-r3
		EGIT_REPO_URI="https://gitlab.com/${GL_USER}/${PN}.git"
	;;
	*)
		SRC_URI="https://${GL_USER}.gitlab.io/dist/${PN}/${P}.tar.gz"
		: ${KEYWORDS:="~amd64 ~x86"}
	;;
esac

IUSE="+terminfo"

DEPEND="terminfo? ( sys-libs/ncurses )
		virtual/libiconv"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

src_compile() {
	emake V=1 $(use terminfo || echo -n "TERMINFO_DISABLE=1")
}

src_install() {
	emake install V=1 prefix="${D%/}/usr"
}
