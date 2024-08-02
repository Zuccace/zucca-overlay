# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="An Old School horisontal scroller 'Shoot Them All' game in bash."
HOMEPAGE="https://github.com/vaniacer/piu-piu-SH"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND=">=app-shells/bash-4.2"

case "$PV" in
	1.1)
		COMMIT="6010c7db501e5fa90b1fe3d7668d2f08b8d81d34"
		KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	;;
	9999)
		inherit git-extra
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
			237)
				COMMIT="b7bd10624c56b2432d245b3ad1c3b0041b405bd5"
			;;
			247)
				COMMIT="b68b3c85b3a55b71153b65148c80b3a62a98dc7b"
			;;
			490)
				# Still 1.1 release...
				COMMIT="b58188aa8055c6506b40303f00e5da93ee21d17f"
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
	dobin "${S}/piu-piu"

	if [ "$EGIT_REPO_URI" ]
	then
		echo "$(git rev-list --count HEAD) $(git rev-parse HEAD)" > "${T}/git_version.txt"
	else
		echo "$COMMIT" > "${T}/git_commit.txt"
	fi

	dodoc "${T}/"*.txt
	find "${S}" -maxdepth 1 -type f -regextype egrep -iregex '^.*/[^/]+\.(md|a?(scii)?doc|txt|nfo|me|pdf|epub)$' -exec dodoc \{\} +
}
