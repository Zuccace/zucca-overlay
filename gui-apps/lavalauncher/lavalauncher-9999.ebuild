# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple launcher for Wayland (sway and wayfire)."
HOMEPAGE="https://git.sr.ht/~leon_plickat/${PN}"
LICENSE="GPL-3"
SLOT="0"

DEPEND="x11-libs/cairo
	dev-libs/wayland
	dev-libs/wayland-protocols"
BDEPEND="app-text/scdoc"

case "$PV" in
	9999*)
		inherit git-r3 meson
		EGIT_REPO_URI="${HOMEPAGE}"
	;;
	*)
		if ver_test -gt 1.3
		then
			inherit meson
		else
			src_install() {
				emake install PREFIX="${ED}/usr"
			}
		fi
		SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tgz"
		KEYWORDS="~amd64 ~x86"
		S="$WORKDIR/${PN}-v${PV}"
	;;
esac

IUSE=""
