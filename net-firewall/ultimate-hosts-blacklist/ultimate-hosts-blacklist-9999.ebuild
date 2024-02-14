# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Very large hosts file for ad/malware/whatnot blocking."
HOMEPAGE="https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist"
LICENSE="BSD"
SLOT="0"

LIVE_URI="https://hosts.ubuntu101.co.za/hosts -> ${PN}.hosts"

RESTRICT="strip"

inherit live-fetch

S="${WORKDIR}"

IUSE="-to-127"

sf="${T}/sources/${PN}.hosts"

src_install() {
	local idir="/usr/share"
	if ! use 'to-127'
	then
		insinto "${idir}"
		newins "${sf}" "${PN}.hosts"
	else
		dodir "${idir}"
		sed 's/^0\.0\.0\.0\s/127.0.0.1 /' "${sf}" > "${ED}/${idir#/}/${PN}.hosts"		
	fi
}
