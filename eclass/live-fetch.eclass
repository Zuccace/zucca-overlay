# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# VERY MUCH WIP!
# The interface/API/file locations may change.

PROPERTIES+=' live'
RESTRICT+=' fetch'

# Takes 'url [-> <file>] ..' formatted arguments separated by newline.
# Nothing fancy. Meaning no conditionals.
live-fetch() {

	local URIFILE URI FILE ARROW DISTDIR="${T}/sources" FCMD="$(echo -e 'import portage\nprint(portage.settings.get("FETCHCOMMAND"))' | python -)"

	mkdir "$DISTDIR" || die "Unable to create directory: ${DISTDIR}"

	local FBIN FARGS
	read FBIN FARGS <<< "$FCMD"
	elog "Using ${FBIN} to download live sources."
	case "${FBIN##*/}" in
		curl)
			# We'll inject --compressed, see 'man curl' for more info.
			FCMD="${FBIN} --compressed ${FARGS}"
		;;
	esac

	elog "Fetch command being used: ${FCMD}"
	
	while read URI ARROW FILE
	do
		if [[ "${ARROW}" != '->' ]]
		then
			# We have no file spacified
			FILE="${URI##*/}"

			# Emit a warning if there's another argument on the line
			if [[ ! -z "${ARROW}" ]]
			then
				eqawarn "An extra argument found from sources. Ignoring it."
				eqawarn "The sources format should be either one URI per line..."
				eqawarn "or 'URI -> FILENAME' per line. No conditionals."
			fi
		elif [[ -z "$URI" ]]
		then
			# Silently skip empty lines
			continue
		else
			if [[ -z "${FILE}" ]]
			then
				eqawarn "No FILE is set, but found -> as an second argument."
				die "Malformed sources list."
			fi
		fi

		ebegin "Downloading live sources form '${URI}'"
		eval "${FCMD}"
		eend "$?"

	done <<< "$@"
}

# It seems that many live eclasses do use src_unpack to fetch the sources.
# So do we.
live-fetch_src_unpack() {
	if [[ ! -z "${LIVE_URI}" ]]
	then
		live-fetch "${LIVE_URI}"
		# We'll need better, more standardized place to put downloaded files. TODO!
		unpack "${T}/sources/"*
	fi
	default
}

EXPORT_FUNCTIONS src_unpack
