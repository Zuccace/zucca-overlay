# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Daemon to scale scale_max_freq when CPU temperature rises"
HOMEPAGE="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/about"
case "${PVR}" in
	0.2)
		GIT_COMMIT="f851f21131a1aab2d9a9449e47876132c2d948c4"
	;;
	0.3)
		GIT_COMMIT="beed43a886451373b3cbfb8bb2a946e74fe16d05"
	;;
	0.4)
		GIT_COMMIT="5a33d25886af8f0996d901fcfc66674a3dc625db"
	;;
	0.5)
		GIT_COMMIT="d669b9c4004a5aaeb026f399bcd3cb5ecfb69630"
	;;
esac

if [[ "$GIT_COMMIT" ]]
then
	[[ -z "$KEYWORDS" ]] && KEYWORDS="~amd64"
	SRC_URI="https://code.pa4wdh.nl.eu.org/tools/cputemp2maxfreq/snapshot/cputemp2maxfreq-$GIT_COMMIT.tar.gz -> ${PF}.tar.gz"
	src_unpack() {
		unpack "${P}.tar.gz"
		mv "cputemp2maxfreq-$GIT_COMMIT" "${P}"
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

	./generate_version_h.sh "${PV}" "${GIT_COMMIT:0:7}" "master" > version.h
	mkdir .git
	touch -d "1 minute ago" .git/index
}

src_install() {
	dosbin "$PN"
	newinitd "gentoo/files/cputemp2maxfreq.init" "$PN"
	newconfd "gentoo/files/cputemp2maxfreq.conf" "$PN"
	[[ "$PV" = '9999' ]] && git_nfo install
}
