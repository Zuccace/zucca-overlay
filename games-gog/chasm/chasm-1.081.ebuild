# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gog

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

UNZIP_LIST=("${GSD%/}/"{Chasm,Content/\*,config.ini,gamecontrollerdb.txt} "${GDD%/}/*" 'data/noarch/support/icon.png')
GOGBINS=("${FGSD%/}/Chasm")
