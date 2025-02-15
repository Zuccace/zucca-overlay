
EAPI=8
SLOT=0

DESCRIPTION="The startx of wayland compositors"
LICENSE="GPL-3"
HOMEPAGE='https://codeberg.org/Zucca/startwayland'

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

#case "$PV" in
#	0.1)
#		KEYWORDS="amd64 ~x86 ~arm arm64 ~riscv ~mips ~alpha ~ppc64 ~ppc ~sparc ~ia64"
#	;;
#esac
