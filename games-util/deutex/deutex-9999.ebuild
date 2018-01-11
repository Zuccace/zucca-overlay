# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="WAD file utility for Doom, Freedoom, Heretic, Hexen, and Strife."
HOMEPAGE="https://github.com/Doom-Utils/deutex"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="png"

RDEPEND="png? ( media-libs/libpng:0/16 )"
DEPEND="sys-devel/automake app-text/asciidoc sys-apps/gawk ${RDEPEND}"

pkg_info() {
	einfo "DeuTex can do many things with Doom, Freedoom, Heretic, Hexen, and Strife "
	einfo "“WAD” files, such as extracting and inserting graphics, sounds, levels, and "
	einfo "other resources. It can be used for creating and modifying IWAD and PWAD files "
	einfo "both."

	einfo "DeuTex began life as a fork of Doom Editing Utilities (known as DEU for short) "
	einfo "by Olivier Montanuy in 1994, expunging the graphical user interface in favor of "
	einfo "command line and scriptable usage scenarios. Originally written for DOS, its "
	einfo "primary home is now Unix systems, and is a fundamental piece to building "
	einfo "Freedoom’s playable WAD files."
	einfo ""
	einfo "The name comes from a play on LaTeX and in turn TeX, a popular typesetting "
	einfo "system in academia but no technical connection to DeuTex. It is pronounced as "
	einfo "two syllables, the first like “due” or “dew,” and the second like "
	einfo "“tech” (not “tex”!), owing from its namesake."
}

case "${PV}" in
	5.0.0_beta2_p12)
		COMMIT="89a523654333c751b6f59c2b38c1529e1ae49363"
	;;
	5.0.0_beta2_p25)
		COMMIT="89ef343ad2761fc967cf2146395b92b2b6cd0333"
	;;
	5.1.0_p165)
		COMMIT="8129d1538de941f9f1c290d20aa8d00d172ed3d1"
		KEYWORDS="amd64 ~x86"
	;;
	5.1.0_p167)
		COMMIT="0c68487448317a73d30588c849ada065491b337a"
	;;
	9999)
		unset KEYWORDS
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		# Offical release
		# Does NOT work with beta releases. So... TODO
		SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	;;
esac

if [ "$COMMIT" ]
then
	SRC_URI="${HOMEPAGE}/archive/${COMMIT}.zip -> ${P}.zip"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

src_prepare() {
	# Add version information to identify installed version if bugs arise.
	if [ "$COMMIT" ]
	then
		GITVERS="$PV"
		echo -e "$GITVERS\n$COMMIT - $(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F)" > git.version
	elif [ "$EGIT_REPO_URI" ]
	then # We are here if version is 9999
		GITVERS="$(git describe)"
		(
			echo "$GITVERS"
			echo "rev $(git rev-list --count HEAD) - $(date --date="$(git show --pretty=%cI HEAD | head -n 1)" +%F)"
			git rev-parse HEAD
		) > git.version
	fi

	awk -i inplace -v "vers=$([ "$GITVERS" ] && echo -n "${GITVERS}-git" || echo -n "$PV") Built on $(date +%F)" '{if (/^AC_INIT\(/) $2 = "[" vers "],"; print}' configure.ac
	default
}

src_configure() {
	./bootstrap
	./configure --prefix="/usr" $(use_with {,lib}png)
}

src_install() {
	default
	[ -f git.version ] && echo "Built on $(date +%F)" >> git.version && dodoc git.version
}
