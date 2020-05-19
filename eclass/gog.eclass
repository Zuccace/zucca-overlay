# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gog.eclass
# @MAINTAINER:
# Ilja Sara <ilja.sara@kahvipannu.com>
# @BLURB: Helper for .sh "packages" downloaded from gog.

: ${RESTRICT:="fetch strip"}

EXPORT_FUNCTIONS src_unpack pkg_nofetch

# @FUNCTION: gog_pkg_unpack
# @USAGE: reaplaces default function
# @DESCRIPTION:
# default unpacking function. Deals .sh files differently. 
gog_src_unpack() {
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
}

# @ECLASS_VARIABLE:	UNZIP_LIST
# @DEFAULT_UNSET	YES
# @REQUIRED		NO
# @DESCRIPTION:
# An array of files or file matching patterns which
# unzip program understands.
# For example: path/to/data/* path/to/one/file.ext
# If left unset then all the files are unpacked using
# internal unpack -function.

# @FUNCTION: gog_pkg_unpack
# @USAGE: reaplaces default function
# @DESCRIPTION:
# Instructs user maybe a little better?
gog_pkg_nofetch() {
	einfo "You need to buy the game from gog.com. Then save the *.sh file to your distdir."
	einfo "${HOMEPAGE}"
}

