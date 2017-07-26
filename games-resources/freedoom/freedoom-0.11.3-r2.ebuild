# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Freedoom - Open Source Doom resources"
HOMEPAGE="https://freedoom.github.io"
SRC_URI="https://github.com/freedoom/freedoom/archive/v${PV}.zip -> freedoom-source-v${PV}.zip"
LICENSE="BSD"
SLOT="$PV"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE="freedoom1 freedoom2 freedm"
REQUIRED_USE="|| ( ${IUSE} )"

DEPEND="
virtual/imagemagick-tools
>games-util/deutex-4.9999"

src_compile() {
	for w in free{doom{1,2},dm}
	do
		use ${w} && emake wads/${w}.wad
	done
}

src_install() {
	insinto "usr/share/games/doom/freedoom/${PV}"

	for w in free{doom{1,2},dm}
	do
		use ${w} && doins wads/${w}.wad
	done

	DOCS="CREDITS README.adoc"
	einstalldocs
}

pkg_postinst() {
	games_pkg_postinst
}
