# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Runs commands when system button/switch states trigger."
HOMEPAGE="https://git.sr.ht/~kennylevinsen/switchd"
LICENSE="BSD"
SLOT="0"

inherit git-extra meson

EGIT_REPO_URI="$HOMEPAGE"

case "$PV" in
	0_p4)
		EGIT_COMMIT="4d3a076e324f442d02f69eb0ee7ea6ab6b7856f0"
	;;
esac

src_install() {
	meson_src_install
	git_nfo install
}
