# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic

DESCRIPTION="A 2D space trading and combat game, in a similar vein to Escape Velocity"
HOMEPAGE="http://naev.org/"
EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
LICENSE="GPL-2 GPL-3 public-domain CC-BY-3.0 CC-BY-SA-3.0"
SLOT="0"
IUSE="debug +mixer +openal"

RDEPEND="
	media-libs/libsdl2[sound,video]
	dev-libs/libzip
	dev-libs/libxml2
	>=media-libs/freetype-2:2
	>=media-libs/libvorbis-1.2.1
	>=media-libs/libpng-1.2:0=
	virtual/glu
	virtual/opengl
	dev-lang/lua:0
	mixer? ( media-libs/sdl2-mixer )
	openal? ( media-libs/openal )
"
BEPEND="${RDEPEND}
	virtual/pkgconfig
"

MY_PV="${PV//_b/-b}"

case "$PV" in
	0.[34].*)
		MY_PN="${PN^^}"
		S="${WORKDIR%/}/${PN}-${MY_PN}-${PV}"
		BDEPEND="${BDEPEND} media-libs/sdl2-image"
		RDEPEND="${RDEPEND} media-libs/sdl2-image"
	;;
	9999)
		true
	;;
	*)
		S="${WORKDIR%/}/${PN}-${PN}-${PV//_b/-b}"
	;;
esac

case "$PV" in
	9999)
		inherit git-r3
	;;
	0.5.[012]*)
		MY_PV="0.5.3"
		SRC_URI="http://kahvipannu.com/~zucca/packages/naev/${MY_PV}--${PV}.xdelta -> ${PN}-${MY_PV}--${PV}.xdelta"
		BDEPEND="${BDEPEND} dev-util/xdelta:3"
		PKGEXT="tar.gz"
	;;
	0.6.[01]*|0.7.0_p*)
		MY_PV="0.7.0"
		SRC_URI="http://kahvipannu.com/~zucca/packages/naev/${MY_PV}--${PV}.xdelta -> ${PN}-${MY_PV}--${PV}.xdelta"
		BDEPEND="${BDEPEND} dev-util/xdelta:3"
		PKGEXT="tar.gz"
	;;
	*)
		PKGEXT="tar.gz"
	;;
esac

: ${MY_PV:="$PV"}

if [[ "$PV"  != "9999" && -z "$EGIT_COMMIT" ]]
then
	: ${KEYWORDS:="~amd64 ~x86"}
	SRC_URI="$SRC_URI
	https://github.com/${PN}/${PN}/archive/${MY_PN:="$PN"}-${MY_PV}.${PKGEXT} -> ${PN}-${MY_PV//-b/_b}.${PKGEXT}"

	src_unpack() {

		if [ -r "${DISTDIR%/}/"*".xdelta" ]
		then
			TARPKG="${T%/}/${P}.tar"
			xdelta3 -d -R -s ${DISTDIR%/}/*.tar.gz ${DISTDIR%/}/*.xdelta "$TARPKG" || die
			unpack "$TARPKG"
		else
			default
		fi
	}

fi

src_configure() {
	./autogen.sh || die
	econf \
		--docdir=/usr/share/doc/${PF} \
		--enable-lua=shared \
		$(use_enable debug) \
		$(use_with openal) \
		$(use_with mixer sdlmixer)
}

src_compile() {
	emake V=1
}

src_install() {
	emake \
		DESTDIR="${D}" \
		appicondir=/usr/share/pixmaps \
		appdatadir=/usr/share/appdata \
		Graphicsdir=/usr/share/applications \
		install

	#insinto /usr/share/${PN}
	#newins "${DISTDIR}"/ndata-${PV}.zip ndata

	#local res
	#for res in 16 32 64 128; do
	#	newicon -s ${res} extras/logos/logo${res}.png naev.png
	#done
	case "$PV" in
		9999)
			TAG="$(git tag | tail -n 1)"
			REV="$(git rev-list --count "${TAG}..HEAD")"
			newdoc <(echo -ne "${TAG}_p${REV}\n$(git rev-parse HEAD)") VERSION.nfo
		;;
	esac
	rm -f "${D}"/usr/share/doc/${PF}/LICENSE
}
