# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# VERY MUCH WIP!
# The interface/API/file locations may change.

inherit envvar

PROPERTIES+=' live'
RESTRICT+=' fetch'

MY_DISTDIR="${T}/sources"

# Takes 'url [->|max age in hours [filename]]' formatted arguments separated by newline.
# Nothing fancy. Meaning no conditionals.
alt-fetch() {
	
	local URIFILE URI FILE AGE COMPRESS dage="$((24*7))" DISTDIR="${PORTAGE_ACTUAL_DISTDIR}/alt-fetch/${CATEGORY}_${PN}" FCMD="$(envvar 'FETCHCOMMAND')"

	mkdir -p "${MY_DISTDIR}" || die
	
	#env | fgrep cache
	
	local FBIN FARGS
	read FBIN FARGS <<< "$FCMD"
	elog "Using ${FBIN} to download live sources."
	case "${FBIN##*/}" in
		curl)
			# We'll inject --compressed, see 'man curl' for more info.
			FCMD="${FBIN} --compressed ${FARGS}"
			#local encodings="lzip zstd xz bzip gzip"
			#FARGS="$(awk -v encodings="${encodings}" '
			#	BEGIN { split(encodings,a); }
			#	{
			#		for (i=1; i<=NF; i++) {
			#			if ($i == "-o" || $i == "--output") {
			#				printf "%s ","--no-compressed"
			#				for (e in a) printf "%s ","--header \"Accept-Encoding: " a[e] "\"";
			#			}
			#			printf "%s ",$i
			#		}
			#	}' <<< "${FARGS}")"
			#FCMD="${FBIN} ${FARGS}"
		;;
	esac

	elog "Fetch command being used: ${FCMD}"

	if [[ ! -d "${DISTDIR}" ]]
	then
		addwrite /
		mkdir -p "${DISTDIR}" || die
	fi
	addwrite "${DISTDIR}"
	
	while read URI AGE FILE COMPRESS
	do
		if [[ -z "${AGE}" ]]
		then
			# We only have an URL.
			# Keep the filename and default age.
			FILE="${URI##*/}"
			AGE="${dage}"
		elif [[ ! -z "${AGE##*[!0-9]*}" ]]
		then
			# AGE is set and is an integer
			if [[ -z "${FILE}" ]]
			then
				FILE="${URI##*/}"
			else
				FILE="${FILE##*/}"
			fi
		elif [[ "${AGE}" = '->' ]]
		then
			AGE="${dage}"
			FILE="${FILE##*/}"
		else
			eqawarn "alt-fetch(): Invalid AGE value: ${AGE}"
			if [[ -z "${FILE}" ]]
			then
				FILE="${URI##*/}"
			else
				FILE="${FILE##*/}"
			fi
		fi

		AGE="$((AGE*3600))"

		# FFILE, full path to the source file, without compression suffix.
		
		local FFILE="${DISTDIR}/${FILE}" tfile
		if ! tfile="$(find "${DISTDIR}" -type f -name "${FILE}.*")" && [[ ! -z "${tfile}" && $(wc -l <<< "${cfile}") -eq 1 ]]
		then
			tfile="${FFILE}"
		fi
				
		if [[ ! -e "${tfile}" || "$(($(stat -c '%Y' "${tfile}")+AGE))" -lt "${EPOCHSECONDS}" ]]
		then
			ebegin "Downloading sources: '${URI}'"

			if [[ -z "$COMPRESS" ]]
			then
				eval "${FCMD}"
				eend "$?"
			else
				local DD="${DISTDIR}"
				DISTDIR="${T}"
				eval "${FCMD}"
				DISTDIR="${DD}"
				unset DD
				eend "$?"

				ebegin "Compressing '${FILE}'"
				"${PORTAGE_COMPRESS:-"gzip"}" "${PORTAGE_COMPRESS_FLAGS:-"-9"}" "${T}/${FILE}"
				eend "$?"
				local CFF="$(printf '%s' "${T}/${FILE}".*)"
				FILE="${CFF##*/}"
				
				mv -v "${CFF}" "${DISTDIR}/" || die
				FFILE="${DISTDIR}/${FILE}"
			fi
		else
			einfo "File '${tfile}' is recent enough, using it."
		fi

		ln -s "${tfile}" "${MY_DISTDIR}/${tfile##*/}"

	done <<< "$@"
}

# It seems that many live eclasses do use src_unpack to fetch the sources.
# So do we.
alt-fetch_src_unpack() {
	if [[ ! -z "${ALT_URI}" ]]
	then
		alt-fetch "${ALT_URI}"
		unpack "${MY_DISTDIR}"/*
	fi
	default
}

EXPORT_FUNCTIONS src_unpack
