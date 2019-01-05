# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils xdg

DESCRIPTION="A map editor for the classic DOOM games, and others such as Heretic and Hexen."
HOMEPAGE="http://eureka-editor.sourceforge.net"
LICENSE="GPL-2+"
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
			SRC_URI="https://downloads.sourceforge.net/project/eureka-editor/${PN^}/${PV}/${PN}-${PKGV}-source.tar.gz -> ${P}.tar.gz"
			S="${WORKDIR%/}/${P}-source"
			KEYWORDS="~amd64 ~x86 ~arm64"
		;;
		git)
			inherit git-r3
			EGIT_REPO_URI="https://git.code.sf.net/p/eureka-editor/git eureka-editor-git"
			DL_TYPE="git"
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
	1.24)
		set_dl_type pkg
	;;
	9999)
		set_dl_type git
	;;
	*)
		die "${PN} ebuild doesn't support the requested version of ${PVR}"
	;;
esac

[ "$EGIT_COMMIT" ] && set_dl_type git

RDEPEND="
	xinerama? ( x11-libs/libXinerama )
	sys-libs/zlib
	media-libs/libpng:0/16
	virtual/jpeg:*
	x11-misc/xdg-utils
	x11-libs/fltk
	x11-libs/libXft"

DEPEND="${RDEPEND}
>=sys-apps/gawk-4.1.0"

src_prepare() {

	[ "$PV" == "9999" ] && EGIT_COMMIT="$(git rev-parse HEAD)"

	if [ "$DL_TYPE" == "git" ] && [ -z "$PATCH_VERS" ]
	then
		PATCH_VERS="git-p$(git rev-list --count HEAD)-gentoo-$(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F) "
	fi

	einfo "Patching Makefile on-the-fly..."
	# Modify PREFIX, drop lines using xdg and adjust few compiler flags.
	gawk -i inplace -v "prefix=${D}/usr" -v "libdir=$(get_libdir)" '{if ($1 ~ "^(INSTALL_)?PREFIX=") sub(/=.+$/,"=" prefix); else if ($1 ~ /^xdg-/) next; else if ($1 ~ /^[a-z]+:$/ && seen != "1") {printf "CFLAGS  += -I/usr/include/fltk\nCXXFLAGS  += -I/usr/include/fltk\nLDFLAGS += -L/usr/" libdir "/fltk/\n\n"; seen="1"} print}' Makefile || die "gawk patching failed."
	# Remove owner settings from install -lines.
	gawk -i inplace '{if ($1 == "install") gsub(/[[:space:]]-o[[:space:]][^[:space:]]+/,""); print}' Makefile || die "gawk patching failed."
	einfo "Makefile patching done."

	if [ "$PATCH_VERS" ]
	then
		einfo "Adding custom version number."
		awk -i inplace -v "cvers=$PATCH_VERS" '{if (/^\s*#define\s+EUREKA_VERSION\s+/) {sub("\"$","",$3); $3=$3 "-" cvers "\""} print}' ./src/main.h
	fi

	default
}

#src_compile() {
#	emake FLTK_PREFIX="/usr/include/fltk"
#}

src_install() {

	if [ "$DL_TYPE" == "git" ] && [ "$PV" != "9999" ]
	then
		echo "$EGIT_COMMIT" > VERSION.nfo
	elif [ "$PV" == "9999" ]
	then
		# Cannot git describe ;(
		#git describe --tags > VERSION.nfo
		git rev-parse HEAD >> VERSION.nfo
	fi

	[ -f VERSION.nfo ] && echo "rev $(git rev-list --count HEAD || echo -n "-")" >> VERSION.nfo && dodoc VERSION.nfo

	doicon -s 32 misc/eureka.xpm
	domenu misc/eureka.desktop

	usr="${D}/usr"
	MY_D="${usr}/share/eureka"
	mkdir -p "$MY_D"
	mkdir -p "${usr}/bin"
	emake PREFIX="$usr" INSTALL_DIR="$MY_D" install

}
