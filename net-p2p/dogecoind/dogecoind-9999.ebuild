# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DB_VER="4.8"

inherit db-use git-r3

DESCRIPTION="Very scrypt! Such random! No such GUI. Much profit! Wow! Many coin!"
HOMEPAGE="http://dogecoin.com/"
EGIT_REPO_URI='https://github.com/dogecoin/dogecoin.git'

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="
	sys-libs/db:5.1[cxx]
	dev-libs/leveldb
	>=dev-libs/boost-1.41.0
	dev-libs/openssl[-bindist]
	net-libs/miniupnpc"

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
#	dobin src/${PN}
#	dodoc doc/README
	emake DESTDIR="$D" install
}

pkg_multilib_strict_check() { true; }
