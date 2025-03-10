
EAPI=8
SLOT=0

HOMEPAGE="https://codeberg.org/Zucca/usertmp.sh"
DESCRIPTION="Script to create temp directories for users on systems where systemd-logind or elogind is absent."

RDEPEND="
	sys-process/procfsps
	>=dev-libs/shlib-zucca-0.0.7.1b
"

case "$PV" in
	9999)
		PROPERTIES="live"
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	0.0.0.*)
		KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~riscv ~mips ~alpha ~ppc64 ~ppc ~sparc ~ia64"
		SRC_URI="https://codeberg.org/Zucca/${PN}.sh/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}.sh"
		RDEPEND="=dev-libs/shlib-zucca-0.0.5 sys-process/procfsps"
	;;
	*a|*b)
		KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~riscv ~mips ~alpha ~ppc64 ~ppc ~sparc ~ia64"
		SRC_URI="https://codeberg.org/Zucca/${PN}.sh/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}.sh"
	;;

	*)
		KEYWORDS="amd64 x86 arm arm64 riscv mips alpha ppc64 ppc sparc ia64"
		SRC_URI="https://codeberg.org/Zucca/${PN}.sh/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}.sh"
	;;

esac
