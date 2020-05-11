# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DESCRIPTION="Versatile resource monitor."
HOMEPAGE="https://github.com/aristocratos/bashtop"
LICENSE="Apache-2.0"
SLOT="0"

RESTRICT="strip"

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
	emake PREFIX="${ED%/}/usr" DOCDIR="$DOCTEMP" install

	[[ -e "$DOCTEMP" ]] && dodoc -r "$DOCTEMP"*
}

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~hppa ~m68k ~s390 ~sparc ~riscv ~mips"

case "$PV" in
	9999)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}.git"
		KEYWORDS=""
		src_install() {
			git_nfo_install
			normal_install
		}
	;;
	*)
		SRC_URI="https://github.com/aristocratos/bashtop/archive/v${PVR}.tar.gz -> ${PF}.tar.gz"
		src_install() { normal_install; }

		if ver_test -ge '0.8.22'
		then
			# A little optimizing...
			true

		elif ver_test -ge '0.8.19'
		then
			src_prepare() {
				ebegin 'Patching Makefile'
				gawk -i inplace '
					{
						print
						if ($1 == "install:") print "\t@mkdir -p $(DESTDIR)$(DOCDIR)"
					}' Makefile || die 'Patching Makefile failed'
				eend "$?"
				default
			}

		elif ver_test -lt '0.8.19'
		then
			src_install() {
				dobin bashtop
			}

		fi
	;;
esac

src_compile() { true; }

DEPEND=">=app-shells/bash-4.4"
BDEPEND=""
