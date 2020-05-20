# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Simple launcher for Wayland (sway and wayfire)."
HOMEPAGE="https://git.sr.ht/~leon_plickat/${PN}"
LICENSE="GPL-3"
SLOT="0"

case "$PV" in
	9999*)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}"
	;;
	*)
		SRC_URI="null"
		KEYWORDS="~amd64 ~x86"
	;;
esac

IUSE=""
