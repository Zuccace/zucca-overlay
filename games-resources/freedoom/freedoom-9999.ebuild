# Copyright 1999-2019 Gentoo Authors
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
			0.11.3_p233)
				COMMIT="08664b9587433265974425085547341a884f2751"
				KEYWORDS=""
			;;
			0.11.3_p263)
				COMMIT="0411e49acd415fee01ce0dc1f6ee57a7e23c7148"
				KEYWORDS=""
			;;
			0.11.3_p274)
				COMMIT="caa6f46a59ba1fd9d10b3bdf1fa9bc0094ba564c"
				KEYWORDS="~amd64 ~x86 ~arm ~arm64"
			;;
			0.11.3_p285)
				COMMIT="bb2fef4f0252039862e5be05af90e56903c8e8f0"
			;;
			0.11.3_p290)
				COMMIT="cd6e7924d6e62559f50045626bb160d3109d4a9a"
			;;
			0.11.3_p294)
				COMMIT="2f520543d36591dcf000b5a607b2bd57dfb96903"
			;;
			0.11.3_p295)
				COMMIT="1b57c6c14db9d7dc0abc37e496884e91f76895c4"
			;;
			0.11.3_p301)
				COMMIT="257781dcd973ed81d8d1b9df0331e572224a2618"
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
