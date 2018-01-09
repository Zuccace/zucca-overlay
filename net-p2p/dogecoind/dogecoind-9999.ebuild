# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="Very scrypt! Such random! No such GUI. Much profit! Wow! Many coin!"
HOMEPAGE="http://dogecoin.com/"
EGIT_REPO_URI='https://github.com/dogecoin/dogecoin.git'

LICENSE="MIT"

if [ "$PV" != "9999" ]
then
	SRC_URI="${EGIT_REPO_URI%.git}/archive/v${PV}.tar.gz -> ${PF}.tar.gz"
	unset EGIT_REPO_URI
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
	S="${WORKDIR}/${PN%d}-${PVR}"
else
	inherit git-r3
fi

SLOT="0"

DEPEND="
	sys-libs/db:5.1[cxx]
	dev-libs/leveldb
	>=dev-libs/boost-1.41.0
	dev-libs/openssl[-bindist]"

RDEPEND="${DEPEND}"

src_configure() {
	./autogen.sh || die "autogen.sh failed"
	CFLAGS="${CFLAGS} -I /usr/include/db5.1/" CXXFLAGS="${CXXFLAGS} -I /usr/include/db5.1/" ./configure --libdir="/usr/$(get_libdir)" --enable-cxx --prefix=/usr --with-gui=no --disable-tests --without-miniupnpc --with-incompatible-bdb || die "configure failed"
 
}

src_compile() {
	# Give any arguments to make and compiling fails
	# https://github.com/bitcoin/bitcoin/issues/7411
	emake
}

src_install() {
	emake DESTDIR="$D" install
}
