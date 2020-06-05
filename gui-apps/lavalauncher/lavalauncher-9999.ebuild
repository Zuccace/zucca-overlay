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
	1.7.1_p44)
		# Last version without configuration file.
		# Further versions WILL break user scripts running lavalaucher.
		EGIT_COMMIT="8d274c17a07337ebe245a3a3230d1537cf35584e"
		KEYWORDS="~amd64 ~x86"
	;&
	9999*|1.7.1_p44)
		inherit git-extra meson
		EGIT_REPO_URI="${HOMEPAGE}"
		src_install() {
			git_nfo install
			meson_src_install
		}
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
