# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A lightweight Matrix Rain for your terminal"
HOMEPAGE="https://github.com/domsson/fakesteak"
RESTRICT="mirror"
LICENSE="CC0"
SLOT="0"

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE}.git"
else
	case "$PV" in
		0.2.4_p26)
			COMMIT="7658eb7cd34f75a2ed038f17b00039fb0566fc19"
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

src_compile() {
	if [ -f ./build ]
	then
		bash ./build || die "Compilation failed."
	else
		default
	fi
}

src_install() {
	if [ ! -f makefile ]
	then
		if [ -f ./bin/charrain ]
		then
			newbin ./bin/charrain "${PN}"
		else
			dobin "./bin/${PN}"
		fi
	else
		emake PREFIX=${ED}/usr install
	fi
}
