# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="WAD file utility for Doom, Freedoom, Heretic, Hexen, and Strife"
HOMEPAGE="https://github.com/Doom-Utils/deutex"
SRC_URI="https://github.com/Doom-Utils/deutex/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE=""

DEPEND="sys-devel/automake app-text/asciidoc"
RDEPEND=""

src_prepare() {
	# Patching using awk, because I've forgotten how to sed propely.
	awk '{if (/^\s*install -p -m /) {sub("install -p","install -D -p"); print $0 "/" $(NF-1)} else print}' Makefile > Makefile.new
	mv -f Makefile{.new,}
	default
}

src_install() {
	emake PREFIX="${D}usr" install
	mv "${D}usr/man/*" "${D}usr/share/man/"
	dodoc COPYING{,.LIB} FAQ INSTALL README TODO VERSION CHANGES
}
