# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="WAD file utility for Doom, Freedoom, Heretic, Hexen, and Strife."
HOMEPAGE="https://github.com/Doom-Utils/deutex"
EGIT_REPO_URI="${HOMEPAGE}.git"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="-*"
IUSE="png"

RDEPEND="png? ( media-libs/libpng:0/16 )"
DEPEND="sys-devel/automake app-text/asciidoc ${RDEPEND}"

src_prepare() {
	# "git rev-parse HEAD" or "git describe"
	awk -v "gitvers=$(git describe)-git Built on $(date +%F)" '{if (/^AC_INIT\(/) $2 = "[" gitvers "],"; print}' configure.ac > configure.ac.new
	mv -f configure.ac{.new,}
	default
}

src_configure() {
	./bootstrap
	use png && ./configure --prefix="/usr" --with-libpng || ./configure --prefix="/usr" --without-libpng
}

src_install() {
	git rev-parse HEAD > git_commit.sha1
	dodoc git_commit.sha1
	default
}
