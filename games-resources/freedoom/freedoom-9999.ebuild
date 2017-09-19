# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Freedoom - Open Source Doom resources"
HOMEPAGE="https://freedoom.github.io"
LICENSE="BSD"
SLOT="$PV"
IUSE="+freedoom1 +freedoom2 +freedm"
REQUIRED_USE="|| ( ${IUSE//+/} )"
KEYWORDS="-amd64 -x86 -arm -arm64"

DEPEND="
app-arch/unzip
dev-python/pillow
>games-util/deutex-4.9999"

SLOTNAME="$PV"
case "$PV" in
	9999*)
		KEYWORDS=""
		inherit git-r3
		EGIT_REPO_URI="https://github.com/freedoom/freedoom.git"
		vers_cmd() {
			cat VERSION
			git describe
			git rev-list --count HEAD
			git rev-parse HEAD
		}
	;;
	*)
		case "$PV" in
			0.11.3_p191)
				COMMIT="9ba4d3c4fdecd412a53c1e82b67c504909be5712"
			;;
			0.11.3_p194)
				COMMIT="617a15354f296601421b96ebf01888cdbbddb710"
			;;
			0.11.3_p195)
				COMMIT="d3038fad309789c3add9a6ec01367794f87bef10"
				KEYWORDS="~amd64 ~x86 ~arm ~arm64"
			;;
			0.11.3_p220)
				COMMIT="d4b25ee4ea72aab47ab0dea05cbe2029d68eec2d"
				KEYWORDS="-amd64 ~arm64"
			;;
			*)
				die "No commit found for version ${PV}."
			;;
		esac
		S="${WORKDIR}/${PN}-${COMMIT}"
		[ "${COMMIT}" ] || die "No commit found for version ${PV}."
		SRC_URI="https://github.com/freedoom/freedoom/archive/${COMMIT}.zip -> ${P}.zip"
		vers_cmd() {
			cat VERSION
			echo "$COMMIT"
		}
	;;
esac

src_compile() {
	for w in free{doom{1,2},dm}
	do
		use ${w} && emake wads/${w}.wad
	done
}

src_install() {
	insinto "usr/share/games/doom/freedoom/${SLOTNAME}"
	vers_cmd > git_version.txt

	for w in free{doom{1,2},dm}
	do
		use ${w} && doins wads/${w}.wad
	done

	DOCS="CREDITS README.adoc git_version.txt"
	einstalldocs
}

pkg_postinst() {
	games_pkg_postinst
}
