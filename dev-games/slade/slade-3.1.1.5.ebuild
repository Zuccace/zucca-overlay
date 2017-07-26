# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit wxwidgets

MY_PV="3.1.1.5"

SRC_URI="https://github.com/sirjuddington/SLADE/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
DESCRIPTION="SLADE3 is a modern editor for Doom-engine based games and source ports"
HOMEPAGE="http://slade.mancubus.net/"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
#S="${WORKDIR}/SLADE-${MY_PV}/dist"
S="${WORKDIR}/SLADE-${MY_PV}"

RDEPEND="x11-libs/wxGTK:3.0[gstreamer]
	media-libs/libsfml
	x11-libs/fltk
	media-libs/ftgl
	media-sound/fluidsynth
	media-libs/freeimage"

DEPEND="dev-util/cmake
$RDEPEND"

src_configure() {
	cmake  -DCMAKE_INSTALL_PREFIX=/usr || die "cmake failed"
}
