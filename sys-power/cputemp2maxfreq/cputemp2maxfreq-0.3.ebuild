# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Daemon to scale scale_max_freq when CPU temperature rises"
HOMEPAGE="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/about"
GIT_COMMIT="beed43a886451373b3cbfb8bb2a946e74fe16d05"
SRC_URI="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/snapshot/cputemp2maxfreq-$GIT_COMMIT.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack()
{
	unpack "${P}.tar.gz"
	mv "cputemp2maxfreq-$GIT_COMMIT" "${P}"
}

src_prepare()
{
	eapply_user

	./generate_version_h.sh "${PV}" "${GIT_COMMIT:0:7}" "master" > version.h
	mkdir .git
	touch -d "1 minute ago" .git/index
}

src_install()
{
	dosbin ${PN}
	newinitd "${FILESDIR}/cputemp2maxfreq.init" cputemp2maxfreq
	newconfd "${FILESDIR}/cputemp2maxfreq.conf" cputemp2maxfreq
}
