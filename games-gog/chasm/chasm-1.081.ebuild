# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gog

IUSE="-system-mono -vanilla-install"

DESCRIPTION="Action-adventure game with procedurally generated world."
SRC_URI="${PN//-/_}_${PV//./_}_52409.sh"

# We might need these...
#RDEPEND="
#	media-libs/libvorbis
#	media-libs/libsdl2"

pkg_nofetch() {
	einfo "You need to buy and download ${PN^} from gog.com."
	einfo "Then save the ${SRC_URI} file to your distdir."
	einfo "${HOMEPAGE}"
}

# TODO: make system-mono work
#UNZIP_LIST=("${GSD%/}/"{Chasm{,.exe},Content/\*,mono{,machine}config,config.ini,gamecontrollerdb.txt} "${GDD%/}/*" 'data/noarch/support/icon.png')
GOGBINS=("${FGSD%/}/Chasm")

src_install() {
	gog_src_install
	if use system-mono && ! use vanilla-install
	then

		elog "You have system-mono USE flag enabled. However Chasm will be installed with a bundled one."
		elog "As soon as we'll get system-mono working with Chasm you'll get it."
		return 0
	
		local f bf
		grep 'data/noarch/game/[^/]*\.dll$' "${T%/}/file.lst" | \
			while read f
			do
				bf="$(basename "$f")"
				einfo "Symlinking: /usr/lib/mono/4.5/${bf}" "/opt/gog/${PN}/${bf}"
				dosym "/usr/lib/mono/4.5/${bf}" "/opt/gog/${PN}/${bf}"
			done
	fi
}
