# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,5,4,3,7} )
inherit distutils-r1

DESCRIPTION="Simple video cutter"
GH_USER="ozmartian"
GH_REPO="${PN}"
HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"
SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/PyQt5"
RDEPEND="
	${PYTHON_DEPS}
	${DEPEND}
	dev-python/pyopengl
	media-video/ffmpeg
	media-video/mediainfo
	media-video/mpv[libmpv]"
BDEPEND="
	${DEPEND}"

src_prepare() {
	default
	# Fixing doc install directory path:
	sed -i -e "s:doc/vidcutter[^/'\"]*:doc/vidcutter-${PV}:g" helpers.py
}
