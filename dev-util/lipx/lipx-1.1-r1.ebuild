# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Linux IPS patching tool"
UP_PN="${PN^}"
GH_ACC="kylon"
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
	1.0)
		SRC_URI="https://raw.githubusercontent.com/${GH_ACC}/${UP_PN}/32b30f6904cb6965058e866d0efad60d7c4fd8f4/${MY_PY} -> ${P}.py"
		MY_PY="${P}.py"
	;;
	1.1)
		SRC_URI="https://raw.githubusercontent.com/${GH_ACC}/${UP_PN}/5fa4fc3ed92a1b66b1755a8de95133be0925d00a/${MY_PY} -> ${P}.py"
		MY_PY="${P}.py"
	;;
	1.2)
		COMMIT="e66dc12c6c22c060e5c24fdf2698d7e6c2543b7b"
	;;
esac

case "$PVR" in
	1.1-r1)
		PATCHES=("${FILESDIR%/}/user-definable-output.patch")
	;;
	1.2-r1)
		PATCHES=("${FILESDIR%/}/${PVR}.patch")
	;;
esac

if [ "$COMMIT" ]
then
	SRC_URI="https://github.com/${GH_ACC}/${UP_PN}/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR%/}/${UP_PN}-${COMMIT}"
fi

#: ${MY_BIN:="${S%/}/${PN}"}
: ${KEYWORDS:="~amd64 ~x86"}

src_unpack() {
	case "$PV" in
		1.0|1.1)
			cp "${DISTDIR%/}/${MY_PY}" ./
		;;
		*)
			default
		;;
	esac
}

src_prepare() {
	default
	sed "1s:^.*\$:#!$(which python3):" "$MY_PY" > "$PN"
	eapply_user
}

src_install() {
	DOCS="$(find ./ -maxdepth 1 -type f | grep -iE '\.(md|me|txt|doc|pdf|a(scii)?doc)|README')"
	default
	dobin "$PN"
}
