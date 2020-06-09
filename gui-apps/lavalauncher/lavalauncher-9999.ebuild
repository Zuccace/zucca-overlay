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
BDEPEND="app-text/scdoc
	${DEPEND}"

setup_git() {
	inherit git-extra meson
	EGIT_REPO_URI="${HOMEPAGE}"
	src_install() {
		git_nfo install
		meson_src_install
	}
}

case "$PV" in
	1.7.1_p77)
		setup_git
		EGIT_COMMIT="f928dfd44ebc27687084ca80c5870943beb6c68f"
		KEYWORDS="~amd64 ~x86"
	;;
	1.7.1_p75)
		setup_git
		EGIT_COMMIT="1175426f28db227c3994afb5ecc28d6128684d15"
		KEYWORDS="~amd64 ~x86"
	;;
	1.7.1_p44)
		setup_git
		# Last version without configuration file.
		# Further versions WILL break user scripts running lavalaucher.
		EGIT_COMMIT="8d274c17a07337ebe245a3a3230d1537cf35584e"
		KEYWORDS="amd64 ~x86"
	;;
	9999*)
		setup_git
	;;
	*)
		# Offical release
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

if ver_test -gt 1.7.1_p44
then
	pkg_post_install() {
		git_nfo
		einfo " "
		einfo "ATTENTION!"
		einfo "Lavalauncher versions never than 1.7.1_p44,"
		einfo "which includes this version just installed,"
		einfo "work with CONFIGURATION FILE instead of the"
		einfo "command line arguments like the earlier versions."
		einfo "Running lavalauncher with the old command line options"
		einfo "won't work anymore."
		einfo "Users are encouraged to read the documentation (man pages)"
		einfo "and create a configuration file for lavalauncher."
		einfo " "
	}
fi

IUSE=""
