# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit wxwidgets cmake-utils

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
	"3.1.2_beta5_p24")
		COMMIT="1e3a5966bdf46d06f7dbc777453fe89052c25996"
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
	MY_PV="${PV//beta/b}"
	S="${WORKDIR}/${PN^^}-${MY_PV}"
	SRC_URI="https://github.com/sirjuddington/SLADE/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
fi

WX_GTK_VER="3.0"

RDEPEND="
	x11-libs/gtk+:2
	x11-libs/wxGTK:${WX_GTK_VER}
	media-libs/libsfml
	x11-libs/fltk
	media-libs/ftgl
	media-sound/fluidsynth
	media-libs/freeimage"

DEPEND="dev-util/cmake
app-portage/gentoolkit
${RDEPEND}"

src_configure() {

	# Patches to disables webkit startup screen. Will get an USE flag eventually.
	find "${WORKDIR}" -type f -name 'CMakeLists.txt' -exec awk -i inplace '{
		if (/^\s*if \(NO_WEBVIEW\)/) {
			del=1; next
		} else if (/^\s*endif \(NO_WEBVIEW\)/) {
			del=0
			print "SET(WX_LIBS ${WX_LIBS} html)"
			next
		} else if (del==1) next
		print
	}' {} \;

	WX_INCLUDE_DIRS="$(equery -qC f -f dir wxGTK:${WX_GTK_VER} | awk '/\/wx$/ {sub(/wx$/,""); printf "%s ",$0}')"
	find "${WORKDIR}" -type f -name 'CMakeLists.txt' -exec awk -v "wxinclude=${WX_INCLUDE_DIRS}" -i inplace '{
		if (/^\s*find_package\(wxWidgets/) {
			print "include_directories(" wxinclude "/usr/include/gtk-2.0/)"
			print "set(wxWidgets_CONFIG_OPTIONS --toolkit=gtk2)"
			print
		} else print
	}' {} \;

	setup-wxwidgets
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
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

	cmake-utils_src_install
}
