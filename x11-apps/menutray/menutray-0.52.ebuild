# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="An application menu through a GTK+ tray status icon."
HOMEPAGE="https://github.com/trizen/${PN}"
SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+locale"

DEPEND=""
RDEPEND="
	>=dev-lang/perl-5.14
	dev-perl/Gtk2
	dev-perl/Data-Dump
	dev-perl/Linux-DesktopFiles
	locale? ( dev-perl/File-DesktopEntry )

"

src_install() {
	dobin menutray
	newdoc README.md "${PN}-README.md"
	insinto /etc/xdg/menutray/
	doins schema.pl
}
