# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DESCRIPTION="RSS and Atom parser (and some format programs)"
HOMEPAGE="https://git.codemadness.org/sfeed/file/README.html"
LICENSE="ISC"
SLOT="0"
#IUSE=""

#RESTRICT="strip"

EGIT_REPO_URI="git://git.codemadness.org/sfeed"

normal_install() {
	DOCTEMP="${T%/}/docs/"
	emake PREFIX="${ED%/}/usr" MANPREFIX="${ED%/}/usr/share/man" DOCPREFIX="$DOCTEMP" install

	[[ -e "$DOCTEMP" ]] && dodoc -r "$DOCTEMP"*
}

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~hppa ~m68k ~s390 ~sparc ~riscv ~mips ~amd64-linux ~x64-cygwin ~x86-cygwin ~arm-linux ~arm64-linux ~ppc64-linux ~x86-linux"

case "$PV" in
	9999)
		inherit git-extra
		KEYWORDS=""
		src_install() {
			git_nfo install
			normal_install
		}
	;;
	*_p[0-9]*)
		# Non tagged version.
		inherit git-r3
		src_install() { normal_install; }
		case "${PV}" in
			0.9.16_p9)
				KEYWORDS="${KEYWORDS/~amd64/amd64}"
				EGIT_COMMIT="785a50c37c11c8e92387f8409d91bd77c41297b2"
			;;
		esac
	;;
	*)
		SRC_URI="https://codemadness.org/releases/${PN}/${PN}-${PV}.tar.gz"
		src_install() { normal_install; }
	;;
esac

if [[ "$COMMIT" ]]
then
	SRC_URI="${HOMEPAGE}/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR%/}/${PN}-${COMMIT}"
fi

DEPEND=""
BDEPEND=""
