# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# VERY MUCH WIP!
# The interface/API/file locations may change.
# Lot's of comments are still missing, so try to read the code.

inherit envvar multiprocessing

PROPERTIES+=' live'
#RESTRICT+=' fetch'
IUSE+=" +compress-sources -verbose-fetch"

BDEPEND+="
	compress-sources?	( app-arch/plzip )
	verbose-fetch?		( sys-apps/pv )"

MY_DISTDIR="${T}/sources"

find_newest_source() {
	# Will also match FILE.* in case we have some compressed format
	find "${ALT_DISTDIR}" \
		\( -type f -or -type l \) \
		\( -name "${1}" -or -name "${1}.*" \) \
		-printf '%Ts\t%p\n' \
		| sort -nr \
		| head -n 1 \
		| cut -f 2
}

needs_update() {
	NEWEST_SOURCE="$(find_newest_source "$1")"
	if [[ -z "${NEWEST_SOURCE}" ]]
	then
		# No file found
		einfo "No cached '${1##*/}'"
		return 0
	elif [[ "$(($(stat -c '%Y' "${NEWEST_SOURCE}")+AGE))" -lt "${EPOCHSECONDS}" ]]
	then
		# File is too old
		lastsize="$(stat -c '%s' "${NEWEST_SOURCE}")"
		einfo "'${1##*/}' is too old."
		return 0
	else
		# We don't need an update
		einfo "'${1##*/}' is new enough."
		return 1
	fi
}

fetch_file() {
	# Expects many variables to be set
	local URI="${1}"
	if [[ -z "${2}" ]]
	then
		local DISTDIR='/dev' FILE='stdout'
	else
		local FILE="${2}"
	fi

	eval "${FCMD}" || die
}

compress_cmd() {
	plzip --best --match-length=273 --threads="${CJOBS}" --dictionary-size=32MiB --keep --stdout
}

fetch_compress() {
	: ${CJOBS:=$(get_makeopts_jobs 2)}
	if [[ -z "${2}" ]]
	then
		fetch_file "${1}" | compress_cmd
	else
		fetch_file "${1}" | compress_cmd > "${DISTDIR}/${2}"
	fi
}

# Takes one of the following:
# - 'url'
# - 'url -> filename'
# - 'url <max age in hours> filename'
# Also if fourth argument is non-empty, the source file will be compressed (with lzip)
# ... before being placed into portage distfiles cache.
# Nothing fancy. Meaning no conditionals.
# Newline separetes records (files to download).
# Fourth argument is still in development.
# Alternative compression methods are under consideration.
alt-fetch() {

	local URIFILE URI FILE AGE COMPRESS lastsize \
		ALT_DISTDIR="${PORTAGE_ACTUAL_DISTDIR}/alt-fetch/${CATEGORY}_${PN}" \
		dage="$((24*7-1))" \
		FCMD="$(envvar 'FETCHCOMMAND')" \
		FBIN FARGS NEWEST_SOURCE

	mkdir -p "${MY_DISTDIR}" || die

	#env | fgrep cache

	read FBIN FARGS <<< "$FCMD"
	elog "Using ${FBIN} to download live sources."
	case "${FBIN##*/}" in
		curl)
			# We'll inject --compressed, see 'man curl' for more info.
			FCMD="${FBIN} --compressed ${FARGS}"
		;;
	esac

	elog "Fetch command being used: ${FCMD}"

	if [[ ! -d "${ALT_DISTDIR}" ]]
	then
		addwrite /
		mkdir -p "${ALT_DISTDIR}" || die
	fi
	addwrite "${ALT_DISTDIR}"

	while read URI AGE FILE COMPRESS
	do
		# Skip empty lines
		[[ -z "${URI}" ]] && continue
		
		unset NEWEST_SOURCE
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
			AGE="${dage}"
			if [[ -z "${FILE}" ]]
			then
				FILE="${URI##*/}"
			else
				FILE="${FILE##*/}"
			fi
		fi

		# If user doesn't want compressed source, so be it. We'll refrain compressing in any case.
		use compress-sources || unset COMPRESS

		if [[ "${AGE}" -eq 0 ]]
		then
			# File is meant to be re-downloaded every time.
			# No point placing it into actual distdir.
			DISTDIR="${MY_DISTDIR}"
			# And no point compressing it either
			ebegin "Downloading '${FILE}'"
			fetch_file "${URI}" "${FILE}"
			eend "$?"
		else
			AGE="$((AGE*3600))"
			DISTDIR="${PORTAGE_ACTUAL_DISTDIR}/alt-fetch/${CATEGORY}_${PN}"

			if needs_update "${FILE}"
			then
				if [[ -z "$COMPRESS" ]]
				then
					fetch_file "${URI}" "${FILE}"
					NEWEST_SOURCE="${DISTDIR}/${FILE}"
				else
					fetch_compress "$URI" "${FILE}.lz"
					NEWEST_SOURCE="${DISTDIR}/${FILE}.lz"
				fi
			fi

			local SOURCE_LINK="${MY_DISTDIR}/${NEWEST_SOURCE##*/}"
			if [[ ! -e "${SOURCE_LINK}" ]]
			then
				ln -s "${NEWEST_SOURCE}" "${SOURCE_LINK}"
			fi
		fi

	done <<< "$@"
}

# It seems that many live eclasses do use src_unpack to fetch the sources.
# So do we.
alt-fetch_src_unpack() {
	if [[ ! -z "${ALT_URI}" ]]
	then
		alt-fetch "${ALT_URI}"
		local sf df
		 : ${CJOBS:=$(get_makeopts_jobs 2)}

		find "${MY_DISTDIR}" -type f,l -name '*.lz' | while read sf
		do
			df="${sf##*/}"
			df="${df%.lz}"
			plzip --keep --decompress --stdout --threads="${CJOBS}" "${sf}" > "${WORKDIR}/${df}"
		done

		DISTDIR="${MY_DISTDIR}"
		find "${DISTDIR}" -type f,l -not -name '*.lz' -printf '%f\n' | while read sf
		do
			unpack "${sf}"
		done
	fi

	# Finally run the default unpacking.
	default
}

EXPORT_FUNCTIONS src_unpack
