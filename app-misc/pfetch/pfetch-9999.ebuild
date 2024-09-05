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
	cat <<- ENDCONF > "${ED}/etc/pfetch.cfg" || die
		# pfetch configuration
	
		# Which information to display.
		# NOTE: If 'ascii' will be used, it must come first.
		# Default: first example below
		# Valid: space separated string
		#
		# OFF by default: shell editor wm de palette
		PF_INFO="ascii title os host kernel uptime pkgs memory"

		# Example: Only ASCII.
		#PF_INFO="ascii"

		# Example: Only Information.
		#PF_INFO="title os host kernel uptime pkgs memory"

		# Separator between info name and info data.
		# Default: unset
		# Valid: string
		#PF_SEP=":"

		# Enable/Disable colors in output:
		# Default: 1
		# Valid: 1 (enabled), 0 (disabled)
		PF_COLOR=1

		# Color of info names:
		# Default: unset (auto)
		# Valid: 0-9
		#PF_COL1=4

		# Color of info data:
		# Default: unset (auto)
		# Valid: 0-9
		#PF_COL2=9

		# Color of title data:
		# Default: unset (auto)
		# Valid: 0-9
		#PF_COL3=1

		# Alignment padding.
		# Default: unset (auto)
		# Valid: int
		#PF_ALIGN=""

		# Which ascii art to use.
		# Default: unset (auto)
		# Valid: string
		#PF_ASCII="openbsd"

		# The below environment variables control more
		# than just 'pfetch' and can be passed using
		# 'HOSTNAME=cool_pc pfetch' to restrict their
		# usage solely to 'pfetch'.

		# Which user to display.
		#USER=""

		# Which hostname to display.
		#HOSTNAME=""

		# Which editor to display.
		#EDITOR=""

		# Which shell to display.
		#SHELL=""

		# Which desktop environment to display.
		#XDG_CURRENT_DESKTOP=""

		# Since you ended up all the way here
		# I'll tell you a secret.
		# pfetch sources this file.
		# So you can add whatever commands here really.
	ENDCONF
}

if [[ ${PVR} =~ ^9999 ]]
then
	inherit git-extra
	EGIT_REPO_URI="${HOMEPAGE##* }.git"
	src_install() {
		dobin "${PN}"
		newdoc "README.md" "README_${PN}.md"
		install_config
	}
else
	src_install() {
		newbin "${DISTDIR}/${PF}.sh" "${PN}"
		newdoc "${DISTDIR}/README_${PF}.md" "README_${PN}.md"
		install_config
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
	1.4.0)
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
