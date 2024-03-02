# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Very large hosts file for ad/malware/whatnot blocking."
HOMEPAGE="https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist"
LICENSE="BSD"
SLOT="0"
RESTRICT="strip"
S="${WORKDIR}"
IUSE="-to-127 -deny-file"
KEYWORDS="~amd64 ~arm64 ~risc-v ~x86 ~mips"

case "${PV}" in
	2.1942.2024.02.25)
		hash='d708caa6785cc7bf3457914e8719ba02d7ea6cd5'
	;;
	2.1944.2024.02.26)
		hash='46e04fad604bf8e13b14599a0328894fbfad274d'
	;;
	2.1952.2024.03.01)
		hash='6c276b998638856aa10c8f86ec344eaaef4c79c9'
	;;
	9999)
		unset KEYWORDS
		inherit alt-fetch
		ALT_URI="https://hosts.ubuntu101.co.za/hosts 23 ${PN}.hosts 1"
		
		if [[ "${USE}" =~ (^| )deny-file( |$) ]]
		then
			ALT_URI+="
			https://hosts.ubuntu101.co.za/superhosts.deny 23 ${PN}.deny 1"
		fi
	;;
esac

if [[ "${hash}" ]]
then
	SRC_URI="
		https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/archive/${hash}.zip -> ${PF}.zip
	"
	src_unpack() {
		# unzip can concatenate files by using -p switch. Nice!
		unzip -p "${DISTDIR}/${A}" "Ultimate.Hosts.Blacklist-${hash}/hosts/*" > "${PN}.hosts" || die "Unzipping hosts file failed."
		if use deny-file
		then
			unzip -p "${DISTDIR}/${A}" "Ultimate.Hosts.Blacklist-${hash}/superhosts.deny/*.deny" > "${PN}.deny" || die "Unzipping hosts deny file failed."
		fi
	}
fi

src_install() {
	local idir="/usr/share"
	if ! use 'to-127'
	then
		insinto "${idir}"
		doins "${PN}.hosts"
		use deny-file && doins "${PN}.deny"
	else
		dodir "${idir}"
		sed 's/^0\.0\.0\.0\s/127.0.0.1 /' "${PN}.hosts" > "${ED}/${idir#/}/${PN}.hosts" || die "Final installation failed performed by sed."
		use deny-file && doins "${PN}.deny"
	fi
}
