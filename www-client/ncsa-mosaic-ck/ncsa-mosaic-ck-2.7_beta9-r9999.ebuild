# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="NCSA Mosaic web browser. Cameron Kaiser's fork."
GITHUB_USER="mistydemeo"
HOMEPAGE=(
	https://github.com/"${GITHUB_USER}"/mosaic-ck
	http://www.floodgap.com/retrotech/machten/mosaic/
)

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/libpng
	virtual/jpeg:62
	x11-libs/motif[png,jpeg]
	x11-libs/libXmu
	x11-proto/printproto
"
DEPEND="
	${DEPEND}
	sys-apps/gawk
"

case "$PVR" in
	2.7_beta9-r2)
		COMMIT="32eb14ee8d65616c953e965c6a8b1d754eedc7a0"
	;;
	*-r9999*)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE[0]}.git"
		KEYWORDS="-amd64 -x86"
	;;
esac

if [ "$COMMIT" ]
then
	SRC_URI="${HOMEPAGE[0]}/archive/${COMMIT}.zip -> ${PF}-${GITHUBUSER}-${COMMIT}.zip"
	S="$WORKDIR/${PN#ncsa-}-${COMMIT}"
fi

src_prepare() {
	gawk -i inplace -v "cflags=${CFLAGS} -DDOCS_DIRECTORY_DEFAULT=\\\\\\\\\\\\\"/usr/share/doc/${PF}/\\\\\\\\\\\\\" -DHOME_PAGE_DEFAULT=\\\\\\\\\\\\\"${HOMEPAGE[1]}\\\\\\\\\\\\\"" \
		'{if (/^\s*customflags =/) $0 = "customflags = " cflags; print}' makefiles/Makefile.linux \
		&& einfo "Configured custom flags." || die "Configuring custom flags failed."
	gawk -i inplace '{
		if (/^\s*#/) next;
		else if (/^\s*png/) {seenpng=1; next}
		else if (/^\s*jpeg/) {seenjpeg=1; next}
		else if (seenpng == 1 && /^\s*$/) {seenpng=0; print "pnglibs = -lpng -lz -lm\npngflags = -DHAVE_PNG\n"}
		else if (seenjpeg == 1 && /^\s*$/) {seenjpeg=0; print "jpeglibs = -ljpeg\njpegflags = -DHAVE_JPEG\n"}
		else print
	}' makefiles/Makefile.linux && einfo "Patched Makefile.linux." || die "Makefile-linux patchinf failed."

	case "$PV" in
		9999*)
			REV="$(git rev-list --count HEAD)"
			echo -e "$(git rev-parse HEAD)\n$(git log --pretty=format:'%h' -n 1) r${REV} $(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F)" > git.version
			gawk -i inplace -v "versext=-${GITHUB_USER}-r${REV}-gentoo-9999" '{if (/^\s*#define MO_VERSION_STRING/) sub(/"$/,versext "\"",$3); print}' src/MOSAIC_VERSION.h
		;;
		*)
			gawk -i inplace -v "versext=-${GITHUB_USER}-r${PV//##*-p}-gentoo" '{if (/^\s*#define MO_VERSION_STRING/) sub(/"$/,versext "\"",$3); print}' src/MOSAIC_VERSION.h
		;;
	esac

	default
}

src_compile() {
	emake linux
}

src_install() {
	mv "src/Mosaic" mosaic-ck
	dobin mosaic-ck
	dodoc CHANGES COPYRIGHT FEATURES AATODO README
	[ -f git.version ] && dodoc git.version
}
