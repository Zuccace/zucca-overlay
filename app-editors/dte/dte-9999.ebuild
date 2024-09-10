# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A small and easy to use console text editor"
GL_USER="craigbarnes"
GL_REPO="${PN}"
HOMEPAGE="https://${GL_USER}.gitlab.io/${PN}/"
LICENSE="GPL-2"
SLOT="0"

IUSE="+terminfo +extras"

case "$PV" in
	1.6|1.7)
		# Yeah. This is not very pretty.
		IUSE="${IUSE} +shift-select"
		DEPEND="shift-select? ( sys-apps/gawk )"
	;;
	1.7_p3398)
		COMMIT="18db93eb577d25efca6d151cf809dd95f9e3522a"
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.8|1.8.2)
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.8.2_p5)
		COMMIT="f6b39d8bb54f8a68208b212c721459d1839afa96"
	;;
	1.8.2_p73)
		COMMIT="6bbe3052c2f1ec8bd6ab61864c378d7faa9c56a7"
		KEYWORDS="~amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.8.2_p86)
		COMMIT="a751c7b3d74cc3d33266fae3edb940cb2105d3f5"
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.8.2_p247)
		COMMIT="0c60ba929cf1e4890a76009f06eb89a2cbec6729"
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.9.1_p190)
		COMMIT="db72bc1057d63ff1d7e697b6e0b0b41e28378214"
	;;
	1.9.1_p193)
		COMMIT="dcce365fe003d0e0e7ecae07b71907b61404be21"
	;;
	1.9.1_p205)
		COMMIT="b354eb0f3385ae19bc3b0193064125dbb27c135b"
	;;
	1.9.1_p221)
		COMMIT="df9619da608df44b00e2edae414a3531502f89d4"
	;;
	1.9.1_p416)
		COMMIT="5d923ff03280f62a8b619dcd6985f63e77c9ef55"
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
	;;
	1.9.1_p781)
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
		COMMIT="85d61e064cb5cd27ad0d38af12d1a7c95528cba8"
	;;
	1.11.1_p364)
		KEYWORDS="amd64 ~x86 ~arm64 ~riscv ~mips"
		COMMIT="200947550a47c03f484b0abc50346f876c1b520c"
	;;
esac

: ${KEYWORDS:="~amd64 ~x86 ~arm64 ~riscv ~mips"}

if [[ "$EGIT_COMMIT" || "$PV" == "9999" ]]
then
	inherit git-r3
	unset KEYWORDS
	EGIT_REPO_URI="https://gitlab.com/${GL_USER}/${PN}.git"
elif [ "$COMMIT" ]
then
	S="${WORKDIR%/}/${PN}-${COMMIT}"
	SRC_URI="https://gitlab.com/${GL_USER}/${PN}/-/archive/${COMMIT}/dte-${COMMIT}.tar.bz2 -> ${P}.tar.bz2"
else
	: ${SRC_URI:="https://${GL_USER}.gitlab.io/dist/${PN}/${P}.tar.gz"}
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
	if [ "$EGIT_REPO_URI" ]
	then
		TAG="$(git tag --sort=-creatordate | head -n 1)"
		REV="$(git rev-list --count "${TAG}..HEAD")"
		COMMIT="$(git rev-parse HEAD)"
		V_FILE="${T%/}/version-${TAG}_p${REV}.nfo"
		echo -ne "${TAG}_p${REV}\nhttps://gitlab.com/${GL_USER}/${PN}/-/archive/${COMMIT}/dte-${COMMIT}.tar.bz2\n" > "$V_FILE"
		#VERSION_STRING="${TAG}_p${REV} - ${COMMIT}"
		git log -1 >> "$V_FILE"
		dodoc "$V_FILE"
	fi
}
