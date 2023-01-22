# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils desktop

DESCRIPTION="A map editor for the classic DOOM games, and others such as Heretic and Hexen."
HOMEPAGE="http://eureka-editor.sourceforge.net"
LICENSE="GPL-2+"
RESTRICT="mirror"
SLOT="0"
IUSE="xinerama"

set_dl_type() {
	case "${1,,}" in
		pkg)
			DL_TYPE="pkg"
			# Versions after 1.07 don't have dot in version string in their source package filename.
			case "${PV}" in
				0.*|1.07)
					PKGV="${PV}"
				;;
				*)
					PKGV="${PV//./}"
				;;
			esac
			SRC_URI="https://downloads.sourceforge.net/project/eureka-editor/${PN^}/${PV%[a-z]}/${PN}-${PKGV}-source.tar.gz -> ${P}.tar.gz"
			S="${WORKDIR%/}/${P}-source"
			: ${KEYWORDS:="~amd64 ~x86 ~arm64"}
		;;
		git)
			inherit git-extra
			if ver_test '1.27' -lt "$PV"
			then
				EGIT_REPO_URI="https://github.com/ioan-chera/eureka-editor.git"
			else
				EGIT_REPO_URI="https://git.code.sf.net/p/eureka-editor/git eureka-editor-git"
			fi
			DL_TYPE="git"
			: ${KEYWORDS:=" "}
		;;
	esac
}

case "${PVR}" in
	1.21-r1)
		EGIT_COMMIT="2c43e820d58f0e97efa1e4c2967e06657fa6a32e"
		KEYWORDS="~amd64 -x86"
		pkg_info() {
			einfo "This unoffical version has new 3D view implementation:"
			einfo
			einfo "3D View : rewrote code to sort the active list of draw-walls,"
			einfo "using custom sorting code (implementing QuickSort)."
			einfo ""
			einfo "It previously used std::sort(), but because our wall-distance"
			einfo "comparison function is \"wonky\" (e.g. can be non-reversable or"
			einfo "non-transitive), it was causing the local std::sort() function"
			einfo "to access elements outside of the list (leading to a CRASH)."
		}
		PATCH_VERS="r1-gentoo"
	;;
	1.24-r1)
		KEYWORDS="~amd64 ~x86"
		set_dl_type git
		EGIT_COMMIT="257a16cddddbd3adaa690a67c7088698d15ed43f"
	;;
	1.24-r2)
		set_dl_type git
		EGIT_COMMIT="00bda541f3c0680449c79a12609c6089493ae684"
	;;
	9999)
		set_dl_type git
		unset KEYWORDS
	;;
	*)
		set_dl_type pkg
	;;
esac

if ver_test "$PV" -gt '1.27'
then
	inherit cmake
	export BUILD_DIR="${WORKDIR%/}/${PN}-${PV}/build"
	export do_cmake=true
fi

[ "$EGIT_COMMIT" ] && set_dl_type git

BDEPEND="
	x11-libs/libXpm
	>=sys-apps/gawk-4.1.0
"

RDEPEND="
	xinerama? ( x11-libs/libXinerama )
	sys-libs/zlib
	media-libs/libpng:0/16
	virtual/jpeg:*
	x11-libs/fltk
	x11-libs/libXft
"

IDEPEND="x11-misc/xdg-utils"

src_prepare() {
 
	[[ "$PV" == "9999" ]] && EGIT_COMMIT="$(git rev-parse HEAD)"

	# Disabled for now
	if [ "$DL_TYPE" == "git" ] && [ -z "$PATCH_VERS" ] && false
	then
		PATCH_VERS="git-p$(git rev-list --count HEAD)-gentoo-$(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F) "
	fi

	if [[ -f Makefile ]]
	then
		einfo "Patching Makefile on-the-fly..."
		# Modify PREFIX, drop lines using xdg and adjust few compiler flags.
		gawk -i inplace -v "prefix=${D}/usr" -v "libdir=$(get_libdir)" '{if ($1 ~ "^(INSTALL_)?PREFIX=") sub(/=.+$/,"=" prefix); else if ($1 ~ /^xdg-/) next; else if ($1 ~ /^[a-z]+:$/ && seen != "1") {printf "CFLAGS  += -I/usr/include/fltk\nCXXFLAGS  += -I/usr/include/fltk\nLDFLAGS += -L/usr/" libdir "/fltk/\n\n"; seen="1"} print}' Makefile || die "gawk patching failed."
		# Remove owner settings from install -lines.
		gawk -i inplace '{if ($1 == "install") gsub(/[[:space:]]-o[[:space:]][^[:space:]]+/,""); print}' Makefile || die "gawk patching failed."
		einfo "Makefile patching done."
	fi

	if [ "$PATCH_VERS" ]
	then
		einfo "Adding custom version number."
		gawk -i inplace -v "cvers=$PATCH_VERS" '{if (/^\s*#define\s+EUREKA_VERSION\s+/) {sub("\"$","",$3); $3=$3 "-" cvers "\""} print}' ./src/main.h
	fi

	if [[ "$do_cmake" ]]
	then
		eapply_user
		mkdir -p "$BUILD_DIR"
		pushd "$BUILD_DIR"
		gawk -i inplace '{
			if ($1 == "option(ENABLE_UNIT_TESTS")
				print "option(ENABLE_UNIT_TESTS \"Unit tests\" OFF)"
			else print
		}' "${BUILD_DIR%/build}/CMakeLists.txt" || die "Disabling tests failed."
		
		cmake_src_prepare
		
		gawk -i inplace '{
			if ($1 == "FLAGS") {
				gsub(/"/,"")
				if (!gsub(/-Wcast-function-type/,"-Wno-cast-function-type")) $0 = $0 " -Wno-cast-function-type"

				# Upstream bug? Well avoid it.
				$0 = $0 " -Wno-error=stringop-truncation"
			}
			print
		}' "${BUILD_DIR%/}/build.ninja" || die "build.ninja patching failed."

	else
		default
	fi
}

src_compile() {
	if [[ "$do_cmake" ]]
	then
		cmake_src_compile
	else
		default
	fi
}

src_install() {

	if [ "$DL_TYPE" == "git" ] && [ "$PV" != "9999" ]
	then
		git_nfo install
	elif [ "$PV" == "9999" ]
	then
		# Cannot git describe ;(
		#git describe --tags > VERSION.nfo
		git rev-parse HEAD >> VERSION.nfo
	fi

	doicon -s 32 misc/eureka.xpm
	domenu misc/eureka.desktop

	usr="${D}/usr"
	MY_D="${usr}/share/eureka"
	mkdir -p "$MY_D"
	mkdir -p "${usr}/bin"
	if [[ "$do_cmake" ]]
	then
		cmake_src_install
	else
		emake PREFIX="$usr" INSTALL_DIR="$MY_D" install
	fi
	dodoc "${FILESDIR%/}/cheatsheet.pdf" docs/*
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
