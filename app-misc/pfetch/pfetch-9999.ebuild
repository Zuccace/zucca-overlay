# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A pretty system information tool written in POSIX sh"
HOMEPAGE="https://github.com/dylanaraps/pfetch https://github.com/Un1q32/pfetch"
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE##* }.git"
	src_install() {
		dobin "${PN}"
		newdoc "README.md" "README_${PN}.md"
	}
else
	src_install() {
		newbin "${DISTDIR}/${PF}.sh" "${PN}"
		newdoc "${DISTDIR}/README_${PF}.md" "README_${PN}.md"
	}

	if [[ "${PV%%.*}" -lt '1' ]]
	then
		author='dylanaraps'
	else
		author='Un1q32'
	fi

	case "${PVR}" in
		0.6.0_p115)
			V='a906ff89680c78cec9785f3ff49ca8b272a0f96b'
		;;
		*)
			V="${PV}"
		;;
	esac
	
	SRC_URI="	https://raw.githubusercontent.com/${author}/pfetch/${V}/pfetch -> ${PF}.sh
			https://raw.githubusercontent.com/${author}/pfetch/${V}/README.md -> README_${PF}.md"
	S="${WORKDIR}"
fi

case "${PV}" in
	0.6.0|0.6.0_p115)
		KEYWORDS="amd64 arm64 x86 ~riscv"
	;;
	9999)
		true
	;;
	*)
		if [[ -z "$KEYWORDS" && "${PV%%.*}" -lt '1' ]]
		then
			KEYWORDS="~amd64 ~arm64 ~x86 ~riscv"
		fi
	;;
esac

pkg_postinst() {
	elog 'pfetch version of 0.6.0_p115 is the last version from Dylan Araps github repository.'
	elog 'Later versions are (so far) from Un1q32. See the homepages of pfetch:'
	elog "${HOMEPAGE/ / and }"
}
