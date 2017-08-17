# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="NCSA Mosaic web browser. Cameron Kaiser's fork."
HOMEPAGE="http://www.floodgap.com/retrotech/machten/mosaic/"
SRCZIP='mosaic27ck11-src.zip'
PIXZIP="ncsa-mosaic-ck-2.7_beta9-r2-mistydemeo-32eb14ee8d65616c953e965c6a8b1d754eedc7a0.zip"
SRC_URI="
	${HOMEPAGE}mosaic27ck11-src.zip
	https://github.com/mistydemeo/mosaic-ck/archive/32eb14ee8d65616c953e965c6a8b1d754eedc7a0.zip -> ${PIXZIP}
"
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

S="${WORKDIR}/mosaic-ck"

pkg_nofetch() {
	einfo "You need to download '${SRCZIP}' manually."
	einfo "The next command (for example) should do it."
	einfo "wget -c --referer='$HOMEPAGE' -U 'mosaic-ck' -O '${DISTDIR}/${SRCZIP}' '${SRC_URI%% *}'"
}

src_unpack() {
	unpack "$SRCZIP"
	for d in {pix,bit}maps
	do
		unzip --nj "${DISTDIR}/${PIXZIP}" "mosaic-ck-32eb14ee8d65616c953e965c6a8b1d754eedc7a0/src/${d}/*" -d "${S}/src/${d}/"
	done
}

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
	gawk -i inplace -v "versext=-gentoo" '{if (/^\s*#define MO_VERSION_STRING/) sub(/"$/,versext "\"",$3); print}' src/MOSAIC_VERSION.h

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
