# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta/eset of themes"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv ~x86"

RDEPEND="
	x11-themes/obsidian-xcursors
	x11-themes/obsidian-icon-theme
	x11-themes/obsidian2-gtk-theme
	x11-themes/wm-icons
	x11-themes/iceicons
	x11-themes/faenza-icon-theme
	eset/fonts
"
