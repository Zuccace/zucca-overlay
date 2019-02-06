# Copyright 1999-2019 Gentoo Authors
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

: "${IUSE:="+doc"}"

WX_GTK_VER="3.0-gtk3"

RDEPEND="
	x11-libs/wxGTK:${WX_GTK_VER}
	media-libs/libsfml
	x11-libs/fltk
	media-libs/ftgl
	media-sound/fluidsynth
	media-libs/freeimage"

DEPEND="dev-util/cmake
app-portage/gentoolkit
${RDEPEND}"

BDEPEND="${DEPEND}"

DESTDIR="${D%/}/usr/"

pkg_pretend() {
	test-flag-CXX -std=c++14 || die "Your compiler needs to support -std=c++14 to be able to build ${P^}. Upgrade or change your compiler accordingly."
}

src_configure() {

	# Patches to disables webkit startup screen. Will get an USE flag eventually.
	# TODO: to be removed soon. We can use -DNO_WEBVIEW=ON
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

	# A (dirty) hack to patch CMakeLists.txt -files to use (wx)gtk3.
	WX_INCLUDE_DIRS="$(equery -qC f -f dir wxGTK:${WX_GTK_VER} | awk '/\/wx$/ {sub(/wx$/,""); printf "%s ",$0}')"
	find "${WORKDIR}" -type f -name 'CMakeLists.txt' -exec awk -v "wxinclude=${WX_INCLUDE_DIRS}" -i inplace '{
		if (/^\s*find_package\(wxWidgets/) {
			print "include_directories(" wxinclude ")"
			print "set(wxWidgets_CONFIG_OPTIONS --toolkit=gtk3)"
			print
		} else print
	}' {} \;

	setup-wxwidgets
	default
}

src_compile() {
	COMPILELOG="${T}/compile.log"

	pushd dist/
	einfo "Running - cmake ../" >> "${COMPILELOG}" 2>&1
	if ! cmake .. >> "${COMPILELOG}" 2>&1
	then
		eerror "Cmake failed."
		einfo "Tail of ${COMPILELOG} ..."
		tail "${COMPILELOG}" | while read L
		do
			eerror "$L"
		done
		die "Aborting... ${COMPILELOG} might reveal the cause."
	fi

	einfo "Running - emake" >> "${COMPILELOG}" 2>&1
	if nonfatal emake VERBOSE=1 2>&1 | tee -a "$COMPILELOG" | awk '/^[^a-zA-Z0-9]*\[\s*[0-9]+\s*%\]/'
	then
		einfo "Compilation succesful."
	else
		eerror "Compilation of ${P^} failed."
		einfo "COMPILE LOG tail:"
		tail "$COMPILELOG" | while read L
		do
			eerror "$L"
		done

		einfo "The whole emake output is located at: ${COMPILELOG}"

		die "Compilation failed."
	fi

	popd

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

	[ -f VERSION.nfo ] && dodoc VERSION.info

	INSTALLLOG="${T}/install.log"
	pushd dist/

	# Keep your hands off my PREFIX!
	# (I've tried to pass values for DESTDIR, PREFIX and CMAKE_INSTALL_PREFIX but _none_ worked.)
	awk -i inplace -v "dest=${DESTDIR}" '{if (/^\s*string\(.*CMAKE_INSTALL_PREFIX/) $0 = "set(CMAKE_INSTALL_PREFIX \"" dest "\")"; print}' cmake_install.cmake || die "awk died"

	if ! nonfatal emake install 2>&1 | tee -a "$INSTALLLOG" | awk '/^[^a-zA-Z0-9]*\[\s*[0-9]+\s*%\]/'
	then
	    local E="$?"
		die "Installation failed. Error: $E"
	fi
	popd

	if use doc
	then
		dodir "/usr/share/doc/${PN}-${PVR}"
		cp -va docs "${D%/}/usr/share/doc/${PN}-${PVR}/scripting"
	fi
}
