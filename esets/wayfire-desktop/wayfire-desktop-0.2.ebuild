# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta/eset of fonts"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv ~x86"

RDEPEND="
	gui-wm/wayfire
	gui-apps/foot
	gui-apps/yambar[wayland]
	gui-libs/wayfire-plugins-extra
	esets/fonts
"

BDEPEND="${RDEPEND}"
