# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Pulls in all (or most) the stuff Zucca uses for his TV game PC"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv ~x86"

BDEPEND="
	acct-user/player
	"

RDEPEND="
	esets/fonts
	sys-apps/util-linux

	gui-wm/cage
	gui-libs/wlroots
	x11-misc/xdg-utils
	gui-libs/xdg-desktop-portal-wlr
	x11-libs/xcb-util-renderutil

	app-misc/cmatrix
	x11-misc/xscreensaver
	gui-apps/swayidle

	x11-terms/cool-retro-term

	net-dns/bind-tools
	net-misc/chrony
	"

S="$WORKDIR"
src_install() {
	insinto "/lib/${PN}/"
	doins "${FILESDIR}/issue.tty1"
	doins "${FILESDIR}/player_X.env"

	install -m 750 -o root -g player -d "${D}/etc/player_images" || die

	insinto /etc/conf.d
	newins "${FILESDIR}/agetty.tty1.conf" agetty.tty1

	exeinto /usr/libexec/player/
	doexe "${FILESDIR}/player_login.sh"
}
