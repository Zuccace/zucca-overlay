
EAPI=8
SLOT=0

DESCRIPTION="A tool to gather components for your custom iniramfs image."
LICENSE="GPL-2"
HOMEPAGE='https://codeberg.org/Zucca/cinitramfs'

RDEPEND="
	app-shells/bash
	dev-util/bbe
	app-alternatives/cpio
	sys-apps/findutils"

case "$PV" in
	9999)
		PROPERTIES="live"
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		SRC_URI="https://codeberg.org/Zucca/${PN}/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}"
	;;	
esac
