# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple video cutter"
GH_USER="ozmartian"
GH_REPO="${PN}"
HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"
LICENSE="GPL-3"
SLOT="0"

case "$PV" in
	9999*)
		inherit git-r3
		EGIT_REPO_URI="${HOMEPAGE}.git"
	;;
	*)
		SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tgz"
		KEYWORDS="~amd64 ~x86"
	;;
esac

PYTHON_COMPAT=( python3_{6,5,4,3,7} )
inherit distutils-r1

IUSE=""

DEPEND="dev-python/PyQt5
		media-video/mpv[libmpv]"
RDEPEND="
	${PYTHON_DEPS}
	${DEPEND}
	dev-python/pyopengl
	media-video/ffmpeg
	media-video/mediainfo"
BDEPEND="
	${DEPEND}"

src_prepare() {
	default
	# Fixing doc install directory path:
	sed -i -e "s:doc/vidcutter[^/'\"]*:doc/vidcutter-${PV}:g" helpers.py || die 'sed failed to patch "helpers.py".'
}
