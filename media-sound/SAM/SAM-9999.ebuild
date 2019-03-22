# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Software Automatic Mouth - Tiny Speech Synthesizer"
GH_USER="vidarh"
GH_REPO="${PN}"
HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"
SRC_URI="http://www.apple-iigs.info/newdoc/sam.pdf -> apple-iigs-SAM-manual.pdf"
LICENSE="Abadonware"
SLOT="0"

case "$PV" in
	9999*)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	0_p145)
		COMMIT="c86ea395743b8ea4ad071c2167fd1f7f96648f7b"
	;;
	*)
		die
	;;
esac

if [ "$COMMIT" ]
then
	: ${KEYWORDS:="~amd64 ~x86 ~arm ~arm64 ~ppc ~ppc64"}
	S="${WORKDIR%/}/${PN}-${COMMIT}"
	SRC_URI="${HOMEPAGE}/archive/${COMMIT}.zip -> ${P}.zip
	${SRC_URI}"
fi

IUSE="+wrapper"

DEPEND=""
RDEPEND="${DEPEND}
	media-libs/libsdl
	wrapper? (
		media-libs/flac
		media-sound/opus-tools
		media-sound/lame
	)
"
BDEPEND="${DEPEND}"

src_compile() {
	emake sam
}

src_install() {
	if use wrapper
	then
		unpack "${FILESDIR%/}/wrapper.sh.xz"
		newbin wrapper.sh sam
		exeinto /usr/libexec/
		doexe sam
	else
		dobin sam
	fi
	dodoc README.md "${DISTDIR%/}/apple-iigs-SAM-manual.pdf"
}
