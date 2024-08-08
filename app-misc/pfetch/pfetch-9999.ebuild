# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A pretty system information tool written in POSIX sh"
HOMEPAGE="https://github.com/dylanaraps/pfetch"
# https://github.com/Un1q32/pfetch This fork seems to get updates.
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE}.git"
	src_install() {
		dobin "${PN}"
		newdoc "README.md" "README_${PN}.md"
	}
else
	src_install() {
		newbin "${DISTDIR}/${PF}.sh" "${PN}"
		newdoc "${DISTDIR}/README_${PF}.md" "README_${PN}.md"
	}

	case "${PVR}" in
		0.6.0_p115)
			V='a906ff89680c78cec9785f3ff49ca8b272a0f96b'
		;;
		*)
			V="${PV}"
		;;
	esac
	
	SRC_URI="	https://raw.githubusercontent.com/dylanaraps/pfetch/${V}/pfetch -> ${PF}.sh
			https://raw.githubusercontent.com/dylanaraps/pfetch/${V}/README.md -> README_${PF}.md"
	S="${WORKDIR}"
fi

case "${PV}" in
	0.6.0)
		KEYWORDS="amd64 arm64 x86 ~riscv"
	;;
	9999)
		KEYWORDS=""
	;;
	*)
		KEYWORDS="~amd64 ~arm64 ~x86 ~riscv"
	;;
esac
