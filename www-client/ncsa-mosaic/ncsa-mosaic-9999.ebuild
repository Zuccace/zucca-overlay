# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Browse the world wide web like it's 1993!"
HOMEPAGE=(
	https://github.com/yotann/ncsa-mosaic
	http://www.ncsa.illinois.edu/enabling/mosaic
)

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/libpng:1.5
	virtual/jpeg:62
	x11-libs/motif[png,jpeg]
	x11-libs/libXmu
	x11-proto/printproto
"
DEPEND="
	${DEPEND}
	sys-apps/gawk
"

case "$PV" in
	2.7_beta6_p20130128)
		COMMIT="af942b933275782ae8403d67a2d84a3df0ffb6fd"
	;;
	9999*)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE[0]}.git"
		KEYWORDS="-amd64 -x86"
	;;
esac

if [ "$COMMIT" ]
then
	SRC_URI="${HOMEPAGE[0]}/archive/${COMMIT}.zip -> ${PF}-${COMMIT}.zip"
	S="$WORKDIR/${PN}-${COMMIT}"
fi

src_prepare() {
	gawk -i inplace -v "cflags=${CFLAGS} -DDOCS_DIRECTORY_DEFAULT=\\\\\\\\\\\\\"/usr/share/doc/${PF}/\\\\\\\\\\\\\" -DHOME_PAGE_DEFAULT=\\\\\\\\\\\\\"${HOMEPAGE[1]}\\\\\\\\\\\\\"" \
		'{if (/^\s*customflags =/) $0 = "customflags = " cflags; print}' makefiles/Makefile.linux || \
		die "Patching Makefile failed."
	gawk -i inplace '{if (/^Exec=/) $0 = "Exec=mosaic"; print}' desktop/Mosaic.desktop

	[ "$PV" = '9999' ] && echo -e "$(git rev-parse HEAD)\n$(git log --pretty=format:'%h' -n 1) $(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F)" > git.version

	default
}

src_compile() {
	emake linux
}

src_install() {
	mv "src/Mosaic" mosaic
	dobin mosaic
	dohtml docs/resources.html
	mv README.old README
	dodoc CHANGES ChangeLog COPYRIGHT FEATURES TODO README
	[ -f git.version ] && dodoc git.version
	doicon --size 256 desktop/Mosaic.png
	domenu desktop/Mosaic.desktop
}
