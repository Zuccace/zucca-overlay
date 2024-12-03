# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Daemon to scale scale_max_freq when CPU temperature rises"
HOMEPAGE="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/about"

if [[ "$PV" != '9999' ]]
then
	[[ -z "$KEYWORDS" ]] && KEYWORDS="~amd64"
	SRC_URI="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/snapshot/cputemp2maxfreq-${PV}.tar.bz2 -> ${PF}.tbz"
	src_unpack() {
		unpack "${PF}.tbz"
		mv "cputemp2maxfreq-${PV}" "${P}"
	}
else
	EGIT_REPO_URI='https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq'
	inherit git-extra
fi

LICENSE="GPL-3"
SLOT="0"
RESTRICT="mirror"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user

	./generate_version_h.sh "${PV}" "${PV}" "master" > version.h
	mkdir .git
	touch -d "1 minute ago" .git/index
}

src_install() {
	dosbin "$PN"
	newinitd "gentoo/files/cputemp2maxfreq.init" "$PN"
	newconfd "gentoo/files/cputemp2maxfreq.conf" "$PN"
	[[ "$PV" = '9999' ]] && git_nfo install
}
