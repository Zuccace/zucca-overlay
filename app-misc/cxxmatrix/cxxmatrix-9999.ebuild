# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="C++ Matrix: The Matrix Reloaded in Terminals"
HOMEPAGE="https://github.com/akinomyoga/cxxmatrix"
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE}.git"
else
	case "$PV" in
		0_p69)
			COMMIT="c8d4ecfb8b6c22bb93f3e10a9d203209ba193591"
		;;
		*)
			SRC_URI="${HOMEPAGE}/archive/refs/tags/v${PV}.tar.gz -> ${PF}.tgz"
		;;
	esac
	
	if [ "$COMMIT" ]
	then
		SRC_URI="${HOMEPAGE}/archive/${COMMIT}.tar.gz -> ${PF}.tgz"
		S="${WORKDIR%/}/${PN}-${COMMIT}"
	else
		S="${WORKDIR%/}/${PF}"
	fi
	KEYWORDS="~amd64"

fi

src_install() {
	dobin cxxmatrix
	doman cxxmatrix.1
	dodoc README.md LICENSE.md
}
