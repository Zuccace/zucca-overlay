# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit wxwidgets

DESCRIPTION="A modern editor for Doom-engine based games and source ports"
HOMEPAGE="http://slade.mancubus.net/"
KEYWORDS="-amd64 -x86"
SLOT="0"
LICENSE="GPL-2"

# Cases for special (testing/unoffical) versions.
case "$PV" in
	"9999")
		inherit git-r3
		unset KEYWORDS
		EGIT_REPO_URI="https://github.com/sirjuddington/SLADE.git"
	;;
	"3.1.2_beta3")
		# Offical release, unoffical SRC_URI.
		KEYWORDS="~amd64 ~x86"
		COMMIT="ec9b2ffd776d078acd8f5c338d6825e35c3bbcc0"
	;;
esac

# set SRC_URI if not already set.
if [ "$COMMIT" ]
then
	SRC_URI="https://github.com/sirjuddington/SLADE/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR}/${PN^^}-${COMMIT}"
elif [ "$PV" != "9999" ]
then
	# An offical release.
	# Needs some adjustment to $S. $PN to UPPERCASE.
	# beta = b on offical package filenames.
	MY_PV="${PV//beta/b}"
	S="${WORKDIR}/${PN^^}-${MY_PV}"
	SRC_URI="https://github.com/sirjuddington/SLADE/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
fi

RDEPEND="x11-libs/wxGTK:3.0[gstreamer]
	media-libs/libsfml
	x11-libs/fltk
	media-libs/ftgl
	media-sound/fluidsynth
	media-libs/freeimage"

DEPEND="dev-util/cmake
${RDEPEND}"

# Fix compilation errors on newer versions.
CXXFLAGS="${CXXFLAGS} -std=c++11"

src_configure() {
	cmake  -DCMAKE_INSTALL_PREFIX=/usr || die "cmake failed"
}
