# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils toolchain-funcs

MY_PN="${PN/+/-plus}"
MY_P="${P/+/-plus}"
DESCRIPTION="Port of ID's doom to SDL and OpenGL, based on prboom 2.5"
HOMEPAGE="http://prboom-plus.sourceforge.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz mirror://gentoo/${PN%+}.png"
#https://downloads.sourceforge.net/project/prboom-plus/prboom-plus/2.5.1.4/prboom-plus-2.5.1.4.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="
	opengl -debug pcre
	$(echo +sdl_{mixer,net,image})
	fluidsynth -portmidi
	+vorbis mp3 +png
"
REQUIRED_USE="
	|| ( fluidsynth portmidi )
"

DEPEND="media-libs/libsdl[joystick,video]
	sdl_mixer? ( media-libs/sdl-mixer )
	sdl_net? ( media-libs/sdl-net )
	fluidsynth? ( media-sound/fluidsynth )
	portmidi? ( media-libs/portmidi )
	pcre? ( dev-libs/libpcre )
	virtual/opengl
	virtual/glu"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--disable-cpu-opt \
		--enable-option-checking \
		--with-waddir="/usr/share/games/doom" \
		#--docdir="${T}/docs" \
		$(use_enable debug) \
		$(use_with pcre) \
		$(use_enable opengl gl) \
		$(use_with {sdl_,}mixer) \
		$(use_with {sdl_,}net) \
		$(use_with {sdl_,}image) \
		$(use_with png) \
		$(use_with vorbis vorbisfile) \
		$(use_with mp3 mad) \
		$(use_with fluidsynth) \
		$(use_with portmidi)
}

src_install() {
	emake DESTDIR="${D}" install
	GBIN="${D}/usr/games/bin"
	install -d "$GBIN"
	mv "${D}/usr/games/prboom"* "$GBIN/" || die "Binaries not found!"
	doman doc/*.{5,6}
	doicon "${DISTDIR}/${PN%+}.png"
	make_desktop_entry "${PN}" "PrBoom"
	einfo "Moving things around"
	find "${D}" -type d -name 'prboom-plus*' -execdir mv {} prboom+-"$PVR" \; -execdir einfo "mv {} prboom+-${PVR}" \;
}

pkg_postinst() {
	games_pkg_postinst
}
