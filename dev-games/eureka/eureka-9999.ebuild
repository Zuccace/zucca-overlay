# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A map editor for the classic DOOM games, and others such as Heretic and Hexen."
HOMEPAGE="http://eureka-editor.sourceforge.net"

inherit eutils xdg

case "${PVR}" in
	1.21-r1)
		COMMIT="2c43e820d58f0e97efa1e4c2967e06657fa6a32e"
		KEYWORDS="~amd64 -x86"
		S="${WORKDIR}/eureka-editor-git-${COMMIT}"
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
	9999)
		inherit git-r3
		EGIT_REPO_URI="https://git.code.sf.net/p/eureka-editor/git"
	;;
	*)
		die "${PN} ebuild doesn't support the requested version of ${PVR}"
	;;
esac

[ ! "$EGIT_REPO_URI" ] && SRC_URI="https://sourceforge.net/code-snapshots/git/e/eu/eureka-editor/git.git/eureka-editor-git-${COMMIT}.zip -> ${P}_${COMMIT}.zip"
LICENSE="GPL-2+"
SLOT="0"
IUSE="xinerama"

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
	[ "$PV" = "9999" ] && PATCH_VERS="git-p$(git rev-list --count HEAD)-gentoo-$(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F) "

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

	if [ "$COMMIT" ]
	then
		echo "$COMMIT" > VERSION.nfo
	elif [ "$EGIT_REPO_URI" ]
	then
		# Cannot git describe ;(
		#git describe --tags > VERSION.nfo
		git rev-parse HEAD >> VERSION.nfo
	fi

	[ -f VERSION.nfo ] && echo "rev $(git rev-list --count HEAD || echo -n "-")" >> VERSION.nfo && dodoc VERSION.nfo

	doicon -s 32 misc/eureka.xpm
	domenu misc/eureka.desktop

	usr="${D}/usr"
	mkdir -p "${usr}/share/eureka"
	mkdir -p "${usr}/bin"
	emake INSTALL_DIR="${usr}/share/eureka" install
}
