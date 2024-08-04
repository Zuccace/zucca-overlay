# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="Browse the world wide web like it's 1993!"
HOMEPAGE="https://github.com/yotann/ncsa-mosaic http://www.ncsa.illinois.edu/enabling/mosaic"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/libpng
	virtual/jpeg
	x11-libs/motif[png,jpeg]
	x11-libs/libXmu
"
#x11-proto/printproto

DEPEND="
	${DEPEND}
	sys-apps/gawk
"

case "$PV" in
	2.7_beta6_p30)
		COMMIT="5d3543df9bf58224b987309fcdf0abac483e8c18"
	;;
	9999*)
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE%% *}.git"
		unset KEYWORDS
	;;
esac

if [[ "$COMMIT" ]]
then
	SRC_URI="${HOMEPAGE%% *}/archive/${COMMIT}.zip -> ${PN}-${PV}-${COMMIT}.zip"
	S="$WORKDIR/${PN}-${COMMIT}"
fi

rsrc_prepare() {
	gawk -i inplace -v "cflags=${CFLAGS} -DDOCS_DIRECTORY_DEFAULT=\\\\\\\\\\\\\"/usr/share/doc/${PF}/\\\\\\\\\\\\\" -DHOME_PAGE_DEFAULT=\\\\\\\\\\\\\"${HOMEPAGE[1]}\\\\\\\\\\\\\"" \
		'{if (/^\s*customflags =/) $0 = "customflags = " cflags; print}' makefiles/Makefile.linux || \
		die "Patching Makefile failed."
	gawk -i inplace '{if (/^Exec=/) $0 = "Exec=mosaic"; print}' desktop/Mosaic.desktop

	default
}

src_compile() {
	emake linux
}

src_install() {
	newbin "src/Mosaic" mosaic
	dodoc docs/resources.html
	mv README.old README
	dodoc CHANGES ChangeLog COPYRIGHT FEATURES TODO README
	if [[ "$EGIT_REPO_URI" ]]
	then
		git_nfo install
	fi
	doicon --size 256 desktop/Mosaic.png
	domenu desktop/Mosaic.desktop
}
