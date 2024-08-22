# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake desktop

#MY_PN="${PN/+/-plus}"
#MY_P="${P/+/-plus}"
DESCRIPTION="Port of ID's Doom to SDL and OpenGL, based on prboom 2.5"
HOMEPAGE="http://prboom-plus.sourceforge.net/"
SRC_URI="https://github.com/coelckers/prboom-plus/archive/refs/tags/v${PV}.tar.gz -> ${PF}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 -arm64 ~x86"
IUSE="
	-debug pcre zlib
	opengl +hi-res
	-net -server
	alsa +midi +fluidsynth -portmidi tracker-music vorbis mp3
"
REQUIRED_USE="
	midi? ( || ( fluidsynth portmidi ) )
	server? ( net )
"

DEPEND="media-libs/libsdl2[opengl?,joystick,video,sound]
	hi-res? ( media-libs/sdl2-image )
	alsa? ( media-libs/alsa-lib:= )
	midi? ( media-libs/sdl2-mixer )
	tracker-music? ( media-libs/dumb:= )
	mp3? ( media-libs/libmad )
	vorbis? ( media-libs/libvorbis )
	net? ( media-libs/sdl2-net )
	fluidsynth? ( media-sound/fluidsynth )
	portmidi? ( media-libs/portmidi )
	pcre? ( dev-libs/libpcre:3 )
	zlib? ( sys-libs/zlib )
	virtual/opengl
	virtual/glu"
RDEPEND="${DEPEND}"

S="${S}/prboom2"

src_configure() {
        local mycmakeargs=(
                -DBUILD_GL="$(usex opengl)"
                -DWITH_IMAGE="$(usex hi-res)"
                -DWITH_MIXER="$(usex midi)"
                -DWITH_NET="$(usex net)"
                -DWITH_PCRE="$(usex pcre)"
                -DWITH_ZLIB="$(usex zlib)"
                -DWITH_MAD="$(usex mp3)"
                -DWITH_FLUIDSYNTH="$(usex fluidsynth)"
                -DWITH_DUMB="$(usex tracker-music)"
                -DWITH_VORBISFILE="$(usex vorbis)"
                -DWITH_PORTMIDI="$(usex portmidi)"
                -DWITH_ALSA="$(usex alsa)"
                -DDOOMWADDIR="${EPREFIX}/usr/share/doom"
                -DPRBOOMDATADIR="${EPREFIX}/usr/share/${PF}"
                -DWAD_DATA_PATH="${EPREFIX}/usr/share/doom"
                -DBUILD_SERVER="$(usex server)"
        )
        cmake_src_configure
}

src_install() {
	cmake_src_install
	doicon -s scalable "ICONS/${PN}.svg"
	domenu ICONS/${PN}.desktop
}

pkg_postinst() {
	games_pkg_postinst
}
