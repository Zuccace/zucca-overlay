# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Multi algorithm cryptocurrency. Wallet. No GUI."
HOMEPAGE="https://myriadcoin.org"
EGIT_REPO_URI='https://github.com/myriadteam/myriadcoin.git'

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
	sys-libs/db:4.8[cxx]
	dev-libs/boost
	dev-libs/openssl[-bindist]"

RDEPEND="${DEPEND}
	net-libs/libbitcoinconsensus"

src_configure() {
	./autogen.sh || die "autogen.sh failed"
	CFLAGS="${CFLAGS} -I /usr/include/db4.8/" CXXFLAGS="${CXXFLAGS} -I /usr/include/db4.8/" ./configure --libdir="/usr/$(get_libdir)" --enable-cxx --prefix=/usr --with-gui=no --disable-tests --without-miniupnpc --with-incompatible-bdb || die "configure failed"
 
}

src_compile() {
	# Give any arguments to make and compiling fails
	# https://github.com/bitcoin/bitcoin/issues/7411
	emake
}

src_install() {
	emake DESTDIR="$D" install
	find "${D}" -depth -name '*bitcoinconsensus.*' -delete
}

