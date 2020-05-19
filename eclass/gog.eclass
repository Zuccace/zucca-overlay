# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gog.eclass
# @MAINTAINER:
# Ilja Sara <ilja.sara@kahvipannu.com>
# @BLURB: Helper for .sh "packages" downloaded from gog.

: ${RESTRICT:="fetch strip"}

IUSE+=" -vanilla-install"

if [[ USE =~ "vanilla-install" ]]
then
	PROPERTIES="interactive"
fi

EXPORT_FUNCTIONS src_unpack pkg_nofetch

# @FUNCTION: gog_pkg_unpack
# @USAGE: reaplaces default function
# @DESCRIPTION:
# default unpacking function. Deals .sh files differently. 
gog_src_unpack() {
	if use vanilla-install
	then
		einfo "Will not unpack the archives as USE=\"vanilla-install\" is set"
	else
	# Left here if we'd need them some day...
	#awk '{if (p == 1) print; else if ($0 == "eval $finish; exit $res") p = 1}' "${DISTDIR%/}/$A" | tar -xzf -

	local src_pkg ext zip_offset zip_archive zip_magic

	zip_magic=$'\x50\x4b\x03\x04'
	
	for src_pkg in $A
	do
		ext="${src_pkg##*.}"
		if [[ "${ext,,}" = "sh" ]]
		then
			zip_archive="${T%/}/gog-${PN}-${PV}.zip"
			# Find the byte offset where the zip file starts:
			((zip_offset=$(grep --byte-offset --only-matching --text "$zip_magic" "${DISTDIR%/}/${src_pkg}" | head -n 1 | grep -Eo '^[0-9]+')+1))
			tail -c +"$zip_offset" "${DISTDIR%/}/${src_pkg}" > "$zip_archive" || die "Failed extracting zip from '${src_pkg}'"
			if [[ "$UNZIP_LIST" ]]
			then
				unzip "$zip_archive" "${UNZIP_LIST[@]}" || die "Failed unzipping '${zip_archive}'"
			else
				unpack "$zip_archive"
			fi
			
			rm -f "$zip_archive"

		else
			nonfatal unpack "$src_pkg"
		fi
	done
	fi
}

# @ECLASS_VARIABLE:	UNZIP_LIST
# @DEFAULT_UNSET	YES
# @DESCRIPTION:
# An array of files or file matching patterns which
# unzip program understands.
# For example: path/to/data/* path/to/one/file.ext
# If left unset then all the files are unpacked using
# internal unpack -function.

# @FUNCTION: gog_pkg_nofetch
# @USAGE: reaplaces default function
# @DESCRIPTION:
# Instructs user maybe a little better?
gog_pkg_nofetch() {
	einfo "You need to buy the game from gog.com. Then save the *.sh file to your distdir."
	einfo "${HOMEPAGE}"
}

# @FUNCTION: gog_vanilla_install
# @USAGE: gog_vanilla_install [.sh installer]
# @DESCRIPTION:
# Performs installation of the package as-is,
# like gog intended it to be installed.
# With no argument gog_vanilla_install will pick
# the fist distfile listed in "$A" that ends with ".sh".
# This is currently WIP. Do not use it.
gog_vanilla_install() {

	local install_script installer

	if [[ -z "$1" ]]
	then
		for install_script in $A
		do
			ext="${install_script##*.}"
			if [[ "${ext,,}" == 'sh' ]]
			then
				run_installer "${DISTDIR%/}/${install_script}"
				break
			fi
		done
	else
		run_installer "${DISTDIR%/}/${1}"
	fi
}

# @FUNCTION: run_installer
# @USAGE: run_installer <.sh installer>
# @INTERNAL
# @DESCRIPTION:
# Helper function for gog_vanilla_install
run_installer() {
	ebegin "Running the installer '${1}'"
	bash "$1" || die "Vanilla installation failed. Maybe unset vanilla-install USE-flag?"
	eend "$?" "'${1}' did not exit with 0."
}
