# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta/eset of seatd based system"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv ~x86"


RDEPEND="
	sys-auth/seatd[builtin,server,-systemd,-elogind]
	!sys-apps/systemd
	!sys-auth/elogind
"
