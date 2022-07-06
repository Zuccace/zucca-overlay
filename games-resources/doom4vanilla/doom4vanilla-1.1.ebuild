# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Doom 2016 the Way 1993 Did It"
HOMEPAGE="https://www.doomworld.com/forum/topic/108725"
LICENSE="freedist"
RESTRICT="mirror"
# We slot this wad.
# This enables user to easily pick the same version as on a multiplayer server.
SLOT="$PV"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc ~ppc64"

BDEPEND="
app-arch/unzip"

SLOTNAME="$PV"

declare -A dropbox_url_hash=(
	[1.1]="6171549kz36bfkx"
	[1.2]="9wpn6d0yadszmxs"
	[2.2]="4jy8cvykoaply47"
	[2.3]="7xj6jnhpgj8dnbj"
	[2.4]="tw115lj8b5tcwaa"
	[2.5]="9m670fqtdeod0vb"
	[2.5.5]="wfhpr508umogprl"
	[2.5.6]="epa6v1fz7fq4e5g"
	[2.5.7]="4b6rsq3wat2xy9w"
	[2.5.8]="4eixfsfhx9ay7eq"
	[2.5.9]="dm390ll3f0wl4ro"
	[3.0]="bt0egvkz5ufa97c"
	[3.1]="l66n6xm343djs4x"
	[3.2]="hbbkez0g5j5dc6b"
	[3.2.1]="hnrwo7z7rgka5hp"
)

SRC_URI="
	http://kahvipannu.com/~zucca/doom/${P}.zip
	https://www.dropbox.com/s/${dropbox_url_hash["$PV"]}/D4V_v${PV}.zip?dl=1 -> ${P}.zip
"

S="$WORKDIR"

src_compile() {
	true
}

src_install() {
	[[ -d "D4V_v${PV}" ]] && cd "D4V_v${PV}"
	find . -type f -regextype egrep -iregex '^.+/[^/]+\.(dll|exe|bat)' -delete
	rm -- *'DOOM2.WAD here'*
	insinto "usr/share/games/doom/doom4vanilla/${SLOTNAME}"
	doins -r *
}
