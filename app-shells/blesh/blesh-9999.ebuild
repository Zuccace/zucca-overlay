# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Bash Line Editor with syntax highlighting, auto suggestions, vim modes, etc."
HOMEPAGE="https://github.com/akinomyoga/ble.sh"

LICENSE="BSD"
SLOT="0"
IUSE="+auto-load"

RESTRICT="mirror"

RDEPEND=">=app-shells/bash-4.0"
BEPEND="make gawk ${RDEPEND}"
KEYWORDS="~x86 ~amd64 ~arm ~arm64 ~riscv"

case "$PV" in
	0.4.0_rc3)
		CONTRIB_HASH="d4f89cf01e2b1cc728958c40659152262b798c83"
		SRC_URI="
			https://github.com/akinomyoga/ble.sh/archive/refs/tags/v0.4.0-devel3.tar.gz -> ${PF}.tar.gz
			https://github.com/akinomyoga/blesh-contrib/archive/${CONTRIB_HASH}.zip -> ${PN}-contrib-${PV}.zip"
		SDIR="ble.sh-0.4.0-devel3"
		S="${WORKDIR}/${SDIR}"
	;;
	0.4.0_rc3_p132)
		CONTRIB_HASH="cbbb1360fa8db9cd04c7b60166343dca91444345"
		BLESH_HASH="b5938192ca588267345dac494fbebc6d2d6fde6b"
		KEYWORDS="x86 amd64 arm arm64 riscv"
	;;
	0.4.0_rc3_p153)
		CONTRIB_HASH="852eece1e099ba714e132009d9fc8f65bfe62792"
		BLESH_HASH="b6344b3be1978695889371de83ac4d15352e4fee"
	;;
	0.4.0_rc3_p154)
		CONTRIB_HASH="852eece1e099ba714e132009d9fc8f65bfe62792"
		BLESH_HASH="adf9ab8197ec3e7d52875e23374491cfd498f524"
	;;
	0.4.0_rc3_p204)
		CONTRIB_HASH="36c2f7d266bdfd1c256ed1a8f607b8ec177fc20f"
		BLESH_HASH="fcbf1ed0e417433d0e56cf90cad111852115dbe2"
	;;
	9999)
		unset KEYWORDS
		inherit git-extra
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
esac

if [[ ! -z "$BLESH_HASH" ]]
then
	SRC_URI="
		https://github.com/akinomyoga/ble.sh/archive/${BLESH_HASH}.tar.gz -> ${PF}.tar.gz
		https://github.com/akinomyoga/blesh-contrib/archive/${CONTRIB_HASH}.zip -> ${PN}-contrib-${PV}.zip"
	SDIR="ble.sh-${BLESH_HASH}"
	S="${WORKDIR}/${SDIR}"
fi

src_unpack() {
	if [ ! "${EGIT_REPO_URI}" ]
	then
		unpack "${PF}.tar.gz"
		unpack "${PN}-contrib-${PV}.zip"
		rmdir -v "${S}/contrib" || die
		mv -v "${WORKDIR}/${PN}-contrib-${CONTRIB_HASH}/" "${S}/contrib" || die "Contrib move failed."
	else
		git-r3_src_unpack
	fi
}

src_prepare() {
	if [ ! "${EGIT_REPO_URI}" ]
	then
		local cstring="gentoo_zucca"
		#find ./ -name '.git*' -depth -delete
		awk -i inplace '{
				if ($1 == "git" && $2 == "submodule" ) {
					print "\techo Skipping git submodule fetching - we already have all we need."
				} else if ($1 ~ /BUILD_GIT_VERSION/) next
				else {
					sub(/ \| .git .+$/,"")
					print
				}
			}' GNUmakefile || die 'awk patching failed.'

		awk -i inplace -v hash="${cstring}" '{
			if (match($0,/\[commit_hash =/)) print substr($0,1,RSTART+RLENGTH) "\"" hash "\"]"
			else print
		}' ble.pp
	fi
	default
}

src_compile() {
	emake -C "${S}"
}

src_install() {

	local DOCDIR="${ED}/usr/share/doc/${PF}"
	emake -C "${S}" install PREFIX=/usr DESTDIR="${ED}" INSDIR_DOC="${DOCDIR}" INSDIR_LICENSE="${DOCDIR}"

	if [[ "${EGIT_REPO_URI}" ]]
	then
		git_nfo install
	fi

	if use auto-load
	then
		insinto /etc/bash/bashrc.d/
		doins "${FILESDIR}/blesh_init"
	fi
	
	#find "${S}" -maxdepth 1 -type f -regextype egrep -iregex '^.*/[^/]+\.(md|a?(scii)?doc|txt|nfo|me|pdf|epub)$' -exec dodoc \{\} +
}
