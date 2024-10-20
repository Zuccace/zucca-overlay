# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A pretty system information tool written in POSIX sh"
HOMEPAGE="https://github.com/dylanaraps/pfetch https://github.com/Un1q32/pfetch"
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"

install_config() {
	mkdir -p "${ED}/etc/env.d" || die
	echo "PF_SOURCE=\"${EROOT}/etc/pfetch.cfg\"" > "${ED}/etc/env.d/20pfetch" || die
	awk '
		($0 == "## Configuration") {
			while (getline != 0 && $1 != "```sh") continue
			print "# pfetch configuration.\n"
			while (getline != 0 && $1 != "```") if (length($0) > 0 && substr($1,1,1) != "#") print "#" $0
				else print
			exit
		}
		END {
			print "\n\n# As you reached this far I will tell you a secret:"
			print "# Since pfetch sources this file, you put practically"
			print "# anything that runs on shell here. ;) Have fun."
		}
	' "$1" > "${ED}/etc/pfetch.cfg"
}

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE##* }.git"
	src_install() {
		dobin "${PN}"
		newdoc "README.md" "README_${PN}.md"
		install_config "README.md"
	}
else
	src_install() {
		newbin "${DISTDIR}/${PF}.sh" "${PN}"
		newdoc "${DISTDIR}/README_${PF}.md" "README_${PN}.md"
		install_config "${DISTDIR}/README_${PF}.md"
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
	1.4.0|1.5.0)
		KEYWORDS="~amd64 ~arm64 ~x86 ~riscv"
	;;
	9999)
		true
	;;
	*)
		# Consider all the rest versions from dylanaraps' repo as unstable.
		if [[ -z "$KEYWORDS" && "${PV%%.*}" -lt '1' ]]
		then
			KEYWORDS="~amd64 ~arm64 ~x86 ~riscv"
		fi
	;;
esac

pkg_postinst() {
	elog "Configure your pfetch trough: ${EROOT}/etc/pfetch.cfg"
	elog ""
	elog 'pfetch version of 0.6.0_p115 is the last version from Dylan Araps github repository.'
	elog 'Later versions are (so far) from Un1q32. See the homepages of pfetch:'
	elog "${HOMEPAGE/ / and }"
}
