# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Freedoom - Open Source Doom resources"
HOMEPAGE="https://freedoom.github.io"
EGIT_REPO_URI="https://github.com/freedoom/freedoom.git"
EGIT_COMMIT="6bef5963f27805819a065b16667edbe66482380d"
LICENSE="BSD"
SLOT="$PV"
KEYWORDS=""
IUSE="+freedoom1 +freedoom2 +freedm"
REQUIRED_USE="|| ( ${IUSE//+/} )"

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
	( cat VERSION && echo "$EGIT_COMMIT" ) > git_version.txt

	for w in free{doom{1,2},dm}
	do
		use ${w} && doins wads/${w}.wad
	done

	DOCS="CREDITS README.adoc git_version.txt"
	einstalldocs
}

pkg_postinst() {
	games_pkg_postinst
}
