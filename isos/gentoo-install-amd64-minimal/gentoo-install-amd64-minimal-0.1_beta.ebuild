# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Gentoo amd64 minimal - .ISO file"
HOMEPAGE="https://gentoo.org"
LICENSE="GPL3"
SLOT="0"
RESTRICT="strip mirrors"
FEATURES="live"
BDEPEND="sec-keys/openpgp-keys-gentoo-release app-crypt/gnupg"
ISO_NAME="${PN#gentoo-}"

KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~riscv ~mips"

S="${WORKDIR}"

inherit alt-fetch gpg

src_unpack() {
	import_gentoo_keys || die 'Refusing to continue because pgp verification failed.'
	local baseurl='https://distfiles.gentoo.org/releases/amd64/autobuilds' isobase
	prepare_fcmd
	alt-fetch "${baseurl}/latest-iso.txt" 2 "gentoo-latest-isos.lst"
	ebegin "Verifying the iso list"
	gpgverify "${T}/sources/gentoo-latest-isos.lst" || die 'List verification failed.'
	eend 0
	isobase=$(gpgcat "${T}/sources/gentoo-latest-isos.lst" | awk -v isoname="$ISO_NAME" '($1 ~ isoname) {print $1}')
	isoname="${isobase##*/}"
	isodest="${ROOT}/var/images/${isoname}"
	if [[ ! -e "$isodest" ]]
	then
		alt-fetch "
			${baseurl}/${isobase}.asc $((24*30*2)) ${isoname}.asc
			${baseurl}/${isobase} $((24*30*2)) ${isoname}
			"
		gpgverify "${T}/sources/${isoname}.asc" || die "ISO file verification failed. Files may have been tampered!"
	fi
}

pkg_postinst() {
	#cd "$S" || die
	if [[ ! -e "$isodest" ]]
	then
		install -d -m 755 "${isodest%/*}" || die
		mv "$(realpath "${T}/sources/${isoname}")" "$isodest" || die
		elog "ISO image stored at '${isodest}'"
		elog "In order to save space, the iso file has been _moved_ from distfiles into '${isodest%/*}'"
		elog "Portage does NOT track this file. iso file cleaning needs to be performen manually (for now)."
	else
		elog "File '${isodest}' already exists in the system."
	fi
}
