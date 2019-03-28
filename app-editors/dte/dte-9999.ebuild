# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A small and easy to use console text editor"
GL_USER="craigbarnes"
GL_REPO="${PN}"
HOMEPAGE="https://${GL_USER}.gitlab.io/${PN}/"
LICENSE="GPL-3"
SLOT="0"

IUSE="+terminfo +extras"

case "$PV" in
	9999*)
		inherit git-r3
		EGIT_REPO_URI="https://gitlab.com/${GL_USER}/${PN}.git"
	;;
	1.6|1.7)
		# Yeah. This is not very pretty.
		IUSE="${IUSE} +shift-select"
		DEPEND="shift-select? ( sys-apps/gawk )"
	;;
esac

if ! [ "$EGIT_REPO_URI" ]
then
	: ${SRC_URI:="https://${GL_USER}.gitlab.io/dist/${PN}/${P}.tar.gz"}
	: ${KEYWORDS:="~amd64 ~x86"}
fi

DEPEND="${DEPEND}
	terminfo? ( sys-libs/ncurses:* )
	virtual/libiconv"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

src_prepare() {
	default

	if [[ "$PV" == "1.6" || "$PV" == "1.7" ]] && use shift-select
	then
		gawk -i inplace '{if ($3 ~ /(un)?select/) next; print}' config/binding/default || die
		cat config/binding/shift-select >> config/binding/default || die
		rm -f config/binding/shift-select || die
	fi

	if use extras
	then
		rsync -haq "${FILESDIR%/}/config" ./ || die
	fi

	MAKE_VARS=(V=1 $(use terminfo || echo -n "TERMINFO_DISABLE=1") BUILTIN_CONFIGS="$(find config/ -type f -not -name '*.*' -printf "%p ")")
}

src_compile() {
	emake "${MAKE_VARS[@]}"
}

src_install() {
	emake install "${MAKE_VARS[@]}" prefix="${D%/}/usr"
}
