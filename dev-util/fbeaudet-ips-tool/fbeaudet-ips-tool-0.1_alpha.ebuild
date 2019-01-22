# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Linux IPS patching tool and a python module"
UP_PN="ips.py"
MY_PN="ips-tool"
GH_ACC="fbeaudet"
HOMEPAGE="https://github.com/${GH_ACC}/${UP_PN}"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=">=dev-lang/python-3.4.8"
BDEPEND="sys-apps/sed"
MY_PY="${PN}.py"

S="$WORKDIR"

case "$PV" in
	0.1_alpha)
		COMMIT="c2e9d10a748bb2335ed06378974736fbaa4defa2"
	;;
esac

#case "$PVR" in
#	0.1_alpha-r1)
#		PATCHES=("${FILESDIR%/}/${PVR}.patch")
#	;;
#esac

if [ "$COMMIT" ]
then
	SRC_URI="https://github.com/${GH_ACC}/${UP_PN}/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR%/}/${UP_PN}-${COMMIT}"
fi

: ${KEYWORDS:="~amd64 ~x86"}

src_prepare() {
	default
	sed "1s:^.*\$:#!$(which python3):" "$UP_PN" > "$MY_PN"
	eapply_user
}

src_install() {
	DOCS="$(find ./ -maxdepth 1 -type f | grep -iE '\.(md|me|txt|doc|pdf|a(scii)?doc)|README')"
	default
	dobin "$MY_PN"
}
