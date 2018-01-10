# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="An Old School horisontal scroller 'Shoot Them All' game in bash."
HOMEPAGE="https://github.com/vaniacer/piu-piu-SH"

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=">=app-shells/bash-4.2"

case "$PV" in
	9999)
		inherit git-r3
		S="$WORKDIR/piu-piu-${PV}"
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		COMMIT_NR="${PVR##*_p}"
		KEYWORDS="~amd64 ~x86 ~arm ~arm64"

		case "$COMMIT_NR" in
			191)
				COMMIT="a40b66eaf4b39ffe714a41f5b0977ca7eda11fc9"
			;;
			208)
				COMMIT="d6f9697b0184579ba41aeb9d6436950a421ac794"
			;;
		esac
	;;
esac

if [ "$COMMIT" ]
then
	SRC_URI="${HOMEPAGE}/archive/${COMMIT}.zip -> ${PF}.zip"
	S="${WORKDIR}/${PN}-SH-${COMMIT}"
fi

src_install() {
	chown root:games "${S}/piu-piu"
	dobin "${S}/piu-piu"

	if [ "$EGIT_REPO_URI" ]
	then
		echo "$(git rev-list --count HEAD) $(git rev-parse HEAD)" > "${T}/git_version.txt"
	else
		echo "$COMMIT" > "${T}/git_commit.txt"
	fi
	
	dodoc "${T}/"*.txt
}
