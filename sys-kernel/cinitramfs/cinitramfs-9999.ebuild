
EAPI=8
SLOT=0

DESCRIPTION="A tool to gather components for your custom iniramfs image."
LICENSE="GPL-2"
HOMEPAGE='https://codeberg.org/Zucca/cinitramfs'

RDEPEND="
	app-shells/bash
	dev-util/bbe
	app-alternatives/cpio
	sys-apps/findutils"

IUSE="+installkernel"

src_install() {
	if ! use installkernel
	then
		# A bare script
		emake DESTDIR="${D}" install-cinitramfs
		emake DESTDIR="${D}" install-init-script
		
		# Get rid of Makefile so that the default function won't perform an install.
		mv Makefile mf || die
	fi

	default
}

pkg_postinst() {
	if use installkernel
	then
		elog "USE=installkernel is set for this install of ${PN}."
		elog "Please edit the initramfs file list at '${ROOT}/etc/kernel/initramfs.lst' for your initramfs needs."
	fi

	# A way to avoid portage constantly complaining about changed config files.
	# We intentionally leave out 'init' script, since it may be userful to track its changes.
	if ! [[ -e "${ROOT}/etc/kernel/initramfs.lst" || -e "${ROOT}/etc/kernel/init_scripts/rc" ]]
	then
		local mf
		[[ -f 'mf' ]] && mf="mf"
		make -f "${mf:-Makefile}" install-extras || die
		elog "Installed premade list and scripts under /etc/kernel. Please review and edit them."
	fi
}


case "$PV" in
	9999)
		PROPERTIES="live"
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		KEYWORDS="~amd64 ~x86 ~arm64 ~mips ~riscv"
		SRC_URI="https://codeberg.org/Zucca/${PN}/archive/${PV}.tar.gz -> ${PF}.tar.gz"
		S="${WORKDIR}/${PN}"
	;;
esac
