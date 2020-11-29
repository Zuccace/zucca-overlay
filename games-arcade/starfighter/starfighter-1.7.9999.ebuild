# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="Project: Starfighter is a side-scrolling shoot 'em up space game"

LICENSE="GPL-3+"
SLOT="0"
IUSE=""
DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-mixer"

case "${PV%%.*}" in
	1)
		HOMEPAGE="http://starfighter.nongnu.org"
		DIR_V="$PV"
		# Remove all but two major version numbers
		while [[ "$DIR_V" =~ ^([0-9]+.){2,} ]] && [[ "$DIR_V" =~ \..+\. ]]
		do
			DIR_V="${DIR_V%.*}"
		done
		S="${WORKDIR}/${P}-src"
		SRC_URI=(http://download{-mirror,}.savannah.gnu.org/releases/${PN}/${DIR_V}/${P}-src.tar.gz)
		KEYWORDS="~amd64 ~x86"
	;;
	*)
		# From version 2 onvards...
		DEPEND="${DEPEND}
			media-libs/sdl2-ttf
			x11-libs/pango"
		KEYWORDS="~amd64 ~x86"
		HOMEPAGE="https://pr-starfighter.github.io"
		SRC_URI="https://github.com/pr-starfighter/starfighter/archive/v${PV}.tar.gz -> ${P}.tar.gz"
		S="${WORKDIR}/${P}"
	;;
esac

RDEPEND="${DEPEND}"

#inherit autotools

# (Literally) Cases for certain versions.
case "$PV" in
	1.5.1)
		unset KEYWORDS
	;;
	*9999)
		unset SRC_URI KEYWORDS
		inherit git-r3
		S="${S%-src}"
		case "$PV" in
		1.7.9999)
			EGIT_REPO_URI="git://git.savannah.gnu.org/starfighter.git"
		;;
		*)
			EGIT_REPO_URI="https://github.com/pr-starfighter/starfighter.git"
		;;
	esac
	;;
esac

src_prepare() {
	eapply_user
	# Rename html documentation directory to 'html'.
	sed -i -e 's/^\s*dist_doc_DATA = .*$/dist_doc_DATA = LICENSES/' -e 's/^\s*nobase_dist_doc_DATA = .*$/nobase_dist_doc_DATA = html\/\*/' Makefile.am
	mv docs html 2> /dev/null

	if [[ -f "./autogen.sh" ]]
	then
		./autogen.sh || die 'autogen.sh failed.'
	else
		eautoreconf -fi
		default
	fi
}

src_configure() {
	MY_VERS=" - Built on $(date +%F)"
	case "$PV" in
		*9999)
			#MY_VERS=" commit #$(git rev-list --count HEAD): $(git rev-parse HEAD)${MY_VERS}"
			TAG="$(git tag --list --sort=-version:refname | tail -n 1)"
			REV="$(git rev-list --count "${TAG:+${TAG}..}HEAD")"
			COMMIT="$(git rev-parse HEAD)"
			MY_VERS="${TAG:+${TAG}_p}${TAG:-Commit # ${REV}} - ${COMMIT}${MY_VERS}"
			# No luck patching configure.ac to insert version. Results in program crashing at the start.
			#awk -v "myvers=${MY_VERS}" 'BEGIN {FS="\\], \\["; OFS="], ["} {if (/^AC_INIT\(/) {$2 = "\"" $2 myvers "\""; gsub(" ","_",$2)} print}' configure.ac > configure.ac.new
			#mv -f configure.ac{.new,}
		;;
		*)
			MY_VERS="${PV}${MY_VERS}"
		;;
	esac
	einfo "Version information: $(tee VERSION.nfo <<< "$MY_VERS")"
	default
}

#src_compile() {
#	emake
#}

src_install() {
	default
	# The default 'make install' puts some Makefiles into doc directory. O.o
	# We'll delete such files here.
	einfo "Removing leftover Makefiles..."
	find "$D" -type f -name 'Makefile*' -exec einfo "	{}" \; -exec rm {} \;
	dodoc "VERSION.nfo"
}
