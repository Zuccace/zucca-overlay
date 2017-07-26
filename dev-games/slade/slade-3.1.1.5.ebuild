# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit wxwidgets

SRC_URI="https://github.com/sirjuddington/SLADE/archive/${PV}.tar.gz -> ${P}.tar.gz"
DESCRIPTION="A modern editor for Doom-engine based games and source ports"
HOMEPAGE="http://slade.mancubus.net/"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"

# Directory name from the tar is in UPPERCASE.
S="${WORKDIR}/${PN^^}-${PV}"

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
