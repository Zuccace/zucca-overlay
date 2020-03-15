# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
#inherit 

DESCRIPTION="Mount Android phones on Linux with adb. No root required."
HOMEPAGE="https://github.com/spion/adbfs-rootless"
LICENSE="BSD"
SLOT="0"
#IUSE=""

RESTRICT="strip"

case "$PVR" in
	9999)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}.git"
		KEYWORDS=""
		src_install() {
			{
				echo "tag: ${TAG:=$(git tag | tail -n 1)}${TAG:-"[notag]"}"
				echo "commit number (since tag): $(git rev-list --count HEAD${TAG:+..${TAG}})"
				echo "commit: $(git rev-parse HEAD)"
			} > "${T%/}/version.nfo"
			dodoc "${T%/}/version.nfo"

			default
		}
	;;
	0_p108)
		COMMIT="5b091a50cd2419e1cebe42aa1d0e1ad1f90fdfad"
		KEYWORDS="~amd64 ~x86"
	;;
esac

if [[ "$COMMIT" ]]
then
	SRC_URI="${HOMEPAGE}/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR%/}/${PN}-${COMMIT}"
fi

DEPEND="
	dev-util/android-tools
	sys-fs/fuse"
BDEPEND="
	$DEPEND
	virtual/pkgconfig
"
