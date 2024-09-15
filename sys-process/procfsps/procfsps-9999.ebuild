
EAPI=8
SLOT=0

DESCRIPTION="'ps' clone which uses /proc to retrieve data"
LICENSE="MIT"
HOMEPAGE='https://codeberg.org/Zucca/procfsps'

# No dependencies. Every system should have
# all the required tools to get this working.

case "$PV" in
	9999)
		PROPERTIES="live"
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~riscv ~mips ~alpha ~ppc64 ~ppc ~sparc ~ia64"
		SRC_URI="https://codeberg.org/Zucca/${PN}/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}"
	;;	
esac
