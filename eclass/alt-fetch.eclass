# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# VERY MUCH WIP!

# The interface/API/file locations WILL change.
# If you use this eclass be prepared to glue pieced together when update comes.
# Lot's of comments are still missing, so try to read the code.

inherit envvar multiprocessing

PROPERTIES+=' live'
#RESTRICT+=' fetch'
IUSE+=" +compress-sources -verbose-fetch"

BDEPEND+="
	compress-sources?	( app-arch/plzip sys-apps/pv )
	verbose-fetch?		( sys-apps/pv )"

MY_DISTDIR="${T}/sources"

# Modifies FCMD if needed
prepare_fcmd() {
	local FBIN FARGS

	if [[ -z "$FCMD" ]]
	then
		FCMD="$(envvar 'FETCHCOMMAND')"
		
		read FBIN FARGS <<< "$FCMD"
		case "${FBIN##*/}" in
			curl)
				# We'll inject --compressed, see 'man curl' for more info.
				FCMD="${FBIN} --compressed ${FARGS}"
			;;
		esac
		elog "Fetch command being used for alt-fetch: ${FCMD}" 1>&2
	fi
}

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
	# In some circumstance the file can exist but zero length.
	# ... So we'll return 0 if that it so.
	if [[ -z "${NEWEST_SOURCE}" ]] || [[ ! -s "$(realpath "${NEWEST_SOURCE}")" ]]
	then
		# No file found.
		einfo "File '${1##*/}' isn't cached yet."
		return 0
	elif [[ "$(($(stat -c '%Y' "${NEWEST_SOURCE}")+AGE))" -lt "${EPOCHSECONDS}" ]]
	then
		# File is too old.
		# Record the last known size of the source
		# so that we can guestimate ETA for download
		# if USE=verbose-download is set.
		# TODO: not implemented yet, should we even?
		lastsize="$(stat -c '%s' "${NEWEST_SOURCE}")"
		einfo "File '${1##*/}' is cached, but old."
		return 0
	else
		# We don't need an update.
		einfo "File '${1##*/}' is new enough."
		return 1
	fi
}

fetch_file() {
	if [[ -z "$FCMD" ]]
	then
		local FCMD
		prepare_fcmd
	fi
	local URI="${1}"
	if [[ -z "${2}" ]]
	then
		local DISTDIR='/dev' FILE='stdout'
	else
		local FILE="${2}"
	fi

	# TODO: add add hacky --referer ?

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

alt-unpack() {
	local sf df
	 : ${CJOBS:=$(get_makeopts_jobs 2)}

	find "${MY_DISTDIR}" -type f,l -name '*.lz' | while read sf
	do
		df="${sf##*/}"
		df="${df%.lz}"
		plzip --keep --decompress --stdout --threads="${CJOBS}" "${sf}" > "${WORKDIR}/${df}" || die "Uncommpressing failed."
	done

	DISTDIR="${MY_DISTDIR}"

	# Do we really need this?
	find "${DISTDIR}" -type f,l -not -name '*.lz' -printf '%f\n' | while read sf
	do
		unpack "${sf}"
	done
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
# And possibility to provide alternative (secondary) sources
# per file will be added later.
# That said: THE API OF THIS ECLASS WILL CHANGE.
alt-fetch() {

	local URIFILE FCMD URI FILE AGE COMPRESS lastsize \
		ALT_DISTDIR="${PORTAGE_ACTUAL_DISTDIR}/alt-fetch/${CATEGORY}_${PN}" \
		dage="$((24*7-1))" \
		NEWEST_SOURCE

	mkdir -p "${MY_DISTDIR}" || die

	prepare_fcmd

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
		alt-unpack
	fi

	# Finally run the default unpacking.
	default
}

EXPORT_FUNCTIONS src_unpack
