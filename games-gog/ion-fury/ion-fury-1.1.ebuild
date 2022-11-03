# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop gog

DESCRIPTION="Cyberpunk themed fps based on the Ken Silverman's Build engine."
HOMEPAGE="https://www.gog.com/en/game/ion_fury"
SRC_URI="${PN//-/_}_${PV//./_}_41247.sh"
# ion_fury_1_1_41247.sh
LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="fetch strip bindist"

S="$WORKDIR"

RDEPEND="
	media-libs/flac-compat
	media-libs/libsdl2"

pkg_nofetch() {
	einfo "You need to buy and download Ion Fury from gog.com."
	einfo "Then save the ${SRC_URI} file to your distdir."
	einfo "${HOMEPAGE}"
}

UNZIP_LIST=("${GSD%/}/"{fury{.grp,.grpinfo,.def,_nodrm.bin},{gamecontrollerdb,legal}.txt} 'data/noarch/support/icon.png')

src_configure() {
	cat > "${T%/}/${PN}" << ENDLAUNCHER
#!/bin/sh

furyhome="\${HOME%/}/.config/fury"
furybindir="${ROOT}/opt/gog/${PN}"

if [ "\$XDG_RUNTIME_DIR" ]
then
	furyrundir="\${XDG_RUNTIME_DIR%/}/${PN}"
elif [ "\$TMPDIR" ]
then
	furyrundir="\${TMPDIR%/}/\${USER}-fury"
else
	furyrundir="\$furyhome"	
fi

for d in "\$furyhome" "\$furyrundir"
do
	if [ ! -d "\$d" ]
	then
		if ! mkdir -p "\$d" && chmod 700 "\$d"
		then
			exit 1
		fi
		
	fi
done

# We'll create symlinks in place of cache files.
if [ "\$furyrundir" != "\$furyhome" ]
then
	for f in grpfiles.cache texturecache texturecache.index
	do
		ff="\${furyhome}/\${f}"
		if [ ! -L "\$ff" ]
		then
			if [ -e "\$ff" ]
			then
				rm "\$ff" || exit 1
			fi
			ln -s "\${furyrundir}/\${f}" "\${ff}"
		fi
	done
fi

# We'll run the game from the temp/cache dir.
# fury.log will be ceated into \$PWD.
# If this directory happens to be read only Ion-Fury will segfault.
cd "\$furyrundir"

exec "\${furybindir}/fury_nodrm.bin" -j "\${furybindir}/" "\$@"
echo "Something went terribly wrong." 1>&2
ENDLAUNCHER
}

src_install() {
	goginto 
	#insinto "/opt/${PN}"
	#exeinto "/opt/${PN}"
	doexe "${GSD%/}/fury_nodrm.bin"
	dodoc "${GSD%/}/legal.txt"
	rm "${GSD%/}/fury_nodrm.bin"
	doins data/noarch/game/*
	dobin "${T%/}/${PN}"

	newicon data/noarch/support/icon.png "${PN}.png"
	make_desktop_entry "$PN" 'Ion Fury' "$PN" Game
}
