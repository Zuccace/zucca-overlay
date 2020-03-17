# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DESCRIPTION="RSS and Atom parser (and some format programs)"
HOMEPAGE="https://git.codemadness.org/sfeed/file/README.html"
LICENSE="ISC"
SLOT="0"
#IUSE=""

#RESTRICT="strip"

inherit git-r3
EGIT_REPO_URI="git://git.codemadness.org/sfeed"

git_nfo_install() {
	{
		TAG="$(git tag --list --sort=-version:refname | head -n 1)"
		echo "tag: ${TAG:-"[notag]"}"
		CNUM="$(git rev-list --count ${TAG:+${TAG}..}HEAD)"
		echo "commit number (since tag): ${CNUM}"
		echo "commit: $(git rev-parse HEAD)"
		echo "PF: ${PN}-${TAG}_p${CNUM}"
	} > "${T%/}/git_version.nfo"
	dodoc "${T%/}/git_version.nfo"
}

normal_install() {
	DOCTEMP="${T%/}/docs/"
	emake PREFIX="${ED%/}/usr" MANPREFIX="${ED%/}/usr/share/man" DOCPREFIX="$DOCTEMP" install

	[[ -e "$DOCTEMP" ]] && dodoc -r "$DOCTEMP"*
}

case "$PV" in
	9999)
		KEYWORDS=""
		src_install() {
			git_nfo_install
			normal_install
		}
	;;
	*_p[0-9]*)
		# Non tagged version.
		KEYWORDS=""
		src_install() { normal_install; }
	;;
	*)
		KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~hppa ~m68k ~s390 ~sh ~sparc ~riscv ~mips ~amd64-linux ~x64-cygwin ~x86-cygwin ~arm-linux ~arm64-linux ~ppc64-linux ~x86-linux"
		EGIT_COMMIT="$PV"
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
