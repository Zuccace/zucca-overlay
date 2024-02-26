# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Very large hosts file for ad/malware/whatnot blocking."
HOMEPAGE="https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist"
LICENSE="BSD"
SLOT="0"
RESTRICT="strip"
S="${WORKDIR}"
IUSE="-to-127"
KEYWORDS="~amd64 ~arm64 ~risc-v ~x86 ~mips"

case "${PV}" in
	2.1942.2024.02.25)
		hash="d708caa6785cc7bf3457914e8719ba02d7ea6cd5"
	;;
	9999)
		unset KEYWORDS
		inherit alt-fetch
		# Re-download if the previous file is older then 23 hours
		ALT_URI="https://hosts.ubuntu101.co.za/hosts 23 ${PN}.hosts 1"
	;;
esac

if [[ "${hash}" ]]
then
	SRC_URI="https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/archive/${hash}.zip -> ${PF}.zip"
	src_unpack() {
		# unzip can concatenate files by using -p switch. Nice!
		unzip -p "${DISTDIR}/${A}" "Ultimate.Hosts.Blacklist-${hash}/hosts/*" > "${PN}.hosts" || die "Unzipping failed."
	}
fi

src_install() {
	local idir="/usr/share"
	if ! use 'to-127'
	then
		insinto "${idir}"
		doins "${PN}.hosts"
	else
		dodir "${idir}"
		sed 's/^0\.0\.0\.0\s/127.0.0.1 /' "${PN}.hosts" > "${ED}/${idir#/}/${PN}.hosts" || die "Final installation failed performed by sed."
	fi
}
