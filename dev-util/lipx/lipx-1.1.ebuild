# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Linux IPS patching tool"
HOMEPAGE="https://github.com/kylon/Lipx"
SRC_URI="https://raw.githubusercontent.com/kylon/Lipx/5fa4fc3ed92a1b66b1755a8de95133be0925d00a/lipx.py"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=dev-lang/python-3.4.8"
BDEPEND="sys-apps/sed"

S="$WORKDIR"
MY_BIN="${S%/}/${PN}"

src_prepare() {
	eapply_user
	sed "1s:^.*\$:#!$(which python3):" "${DISTDIR%/}/${A}" > "$MY_BIN"
}

src_install() {
	einfo "Installing $MY_BIN"
	dobin "$MY_BIN"
}
