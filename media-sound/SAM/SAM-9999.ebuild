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
	*)
		die
	;;
esac

IUSE="+wrapper"

DEPEND=""
RDEPEND="${DEPEND}"
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
