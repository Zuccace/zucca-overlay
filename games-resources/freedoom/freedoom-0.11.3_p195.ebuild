# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Freedoom - Open Source Doom resources"
HOMEPAGE="https://freedoom.github.io"
LICENSE="BSD"
SLOT="$PV"
IUSE="+freedoom1 +freedoom2 +freedm"
REQUIRED_USE="|| ( ${IUSE//+/} )"

DEPEND="
app-arch/unzip
virtual/imagemagick-tools
>games-util/deutex-4.9999"

declare -A COMMIT
COMMIT=(
	[0.11.3_p191]="9ba4d3c4fdecd412a53c1e82b67c504909be5712"
	[0.11.3_p194]="617a15354f296601421b96ebf01888cdbbddb710"
	[0.11.3_p195]="d3038fad309789c3add9a6ec01367794f87bef10"
)

SLOTNAME="$PV"
case "$PV" in
	*)
		KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	;;
esac

C="${COMMIT[$PV]}"
S="${WORKDIR}/${PN}-${C}"
[ "${C}" ] || die "No commit found for version ${PV}."
SRC_URI="https://github.com/freedoom/freedoom/archive/${C}.zip -> ${P}.zip"
vers_cmd() {
	cat VERSION
	echo "$C"
}

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
