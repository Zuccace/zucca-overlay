# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop gog

DESCRIPTION="Unforgiving beat 'em up roguelite"
HOMEPAGE="https://www.gog.com/game/ascendant"
SRC_URI="gog_ascendant_${PV}.sh"
LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
S="$WORKDIR"

pkg_nofetch() {
	einfo "You need to download the (free!) game from gog.com. Then save the ${SRC_URI} file to your distdir."
	einfo "${HOMEPAGE}"
}

UNZIP_LIST=("${GDD%/}/*" "$GICON")

pkg_setup() {
	if use amd64
	then
		datasource='Ascendant_64_Data'
		mainbin='Ascendant_64.x86_64'
		UNZIP_LIST+=("${GSD%/}/${datasource}/*" "${GSD%/}/$mainbin")
	elif use x86
	then
		datasource='Ascendant_Data'
		mainbin='Ascendant.x86'
		UNZIP_LIST+=("${GSD%/}/${datasource}/*" "${GSD%/}/$mainbin")
	else
		# In case user forces the install on non-supported platform...
		ewarn "This package provides only 32-bit and 64-bit binaries for x86"
		ewarn "architectures (x86 and x86_64)."
		ewarn "Installing both versions as specified architecture isn't either."
		ewarn "You might need to use virtualization or some kind of emulation."
		ewarn "You're on your own."
		unset UNZIP_LIST
	fi
}

src_configure() {

	einfo "$(rm -v "${GDD%/}/"*install*.txt)"
}

src_install() {

	destdir="/opt/${PN}"
	dodoc "${GDD}"/*	
	insinto "$destdir"
	
	pushd "$FGSD" &> /dev/null || die

	if [[ "$mainbin" ]]
	then
		exeinto "$destdir"
		doins -r "$datasource"
		doexe "$mainbin"
		dosym "../..${destdir%/}/${mainbin}" "/usr/bin/${PN,,}"
		newicon "${WORKDIR%/}/$GICON" "${PN}.png"
		make_desktop_entry "/usr/bin/${PN,,}" "$PN" "$PN"
	else
		einfo "Installing _both_ 32-bit and 64-bit versions of ${PN}."
		doins -r *
	fi
	
	popd &> /dev/null || die
}

pkg_postinst() {
	if [[ ! "$mainbin" ]]
	then
		einfo "Game data and binaries installed into ${destdir}."
	fi
}
