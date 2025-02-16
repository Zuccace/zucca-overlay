# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta/eset of common tools for system set"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 arm64 riscv x86"

RDEPEND="
	app-admin/doas
	app-portage/gentoolkit
	app-portage/portage-utils
	app-eselect/eselect-repository
	dev-vcs/git
	app-editors/dte
	sys-fs/ncdu
	app-text/tree
	sys-process/htop
	sys-process/bashtop
	sys-process/btop
	app-misc/nnn
	app-misc/pfetch
	app-misc/fastfetch
	app-misc/tmux
	sys-apps/hdparm
	sys-apps/usbutils
	sys-power/cpupower
	sys-apps/lm-sensors
	app-admin/pass
"
