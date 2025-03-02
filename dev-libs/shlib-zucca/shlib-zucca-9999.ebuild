
EAPI=8
SLOT=0

DESCRIPTION="sh lib by Zucca."
LICENSE="MIT"
HOMEPAGE='https://codeberg.org/Zucca/shlib-zucca.sh'

# No dependencies. Every system should have
# all the required tools to get this working.

case "$PV" in
	9999)
		PROPERTIES="live"
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*a|*b)
		# Alpha and beta releases.
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

case "$PV" in
	0.1)
		KEYWORDS="amd64 ~x86 ~arm arm64 ~riscv ~mips ~alpha ~ppc64 ~ppc ~sparc ~ia64"
	;;
esac
