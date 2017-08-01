# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit wxwidgets

DESCRIPTION="A modern editor for Doom-engine based games and source ports"
HOMEPAGE="http://slade.mancubus.net/"
SLOT="0"
LICENSE="GPL-2"

# Cases for special (testing/unoffical) versions.
case "$PVR" in
	"9999")
		inherit git-r3
		unset KEYWORDS
		EGIT_REPO_URI="https://github.com/sirjuddington/SLADE.git"
	;;
	"3.1.2_beta3")
		# Offical release, unoffical SRC_URI.
		COMMIT="ec9b2ffd776d078acd8f5c338d6825e35c3bbcc0"
	;;
	"3.1.2_beta3_p1")
		COMMIT="2268446c940a8e2b875fc638b625d2d5f148cf64"
	;;
	"3.1.2_beta3_p2")
		COMMIT="9da08eacffd257807590cb053b1c5a051aa4d803"
	;;
esac

# set SRC_URI if not already set.
if [ "$COMMIT" ]
then
	# An unoffical release.
	: ${KEYWORDS:="-amd64 -x86"}
	SRC_URI="https://github.com/sirjuddington/SLADE/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR}/${PN^^}-${COMMIT}"
elif [ "$PV" != "9999" ]
then
	# An offical release.
	: ${KEYWORDS:="~amd64 ~x86"}
	# Needs some adjustment to $S. $PN to UPPERCASE.
	# beta = b on offical package filenames.
	einfo "Preparing for offical release..."
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

src_install() {
	if [ "$COMMIT" ]
	then
		echo "$COMMIT" > VERSION.nfo
	elif [ "$EGIT_REPO_URI" ]
	then
		git describe --tags > VERSION.nfo
		git rev-parse HEAD >> VERSION.nfo
	fi

	[ -f VERSION.nfo ] && dodoc VERSION.nfo

	default
}
