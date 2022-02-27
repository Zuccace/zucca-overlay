# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Runs commands when system button/switch states trigger."
HOMEPAGE="https://git.sr.ht/~kennylevinsen/switchd"
LICENSE="BSD"
SLOT="0"

inherit git-extra meson

EGIT_REPO_URI="$HOMEPAGE"
