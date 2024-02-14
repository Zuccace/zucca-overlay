
PROPERTIES+=' live'
RESTRICT+=' fetch'

# Takes 'url [-> <file>] ..' formatted arguments separated by newline.
# Nothing fancy. Meaning no conditionals.
live-fetch() {

	local URIFILE URI FILE ARROW DISTDIR="${T}/sources" FCMD="$(echo -e 'import portage\nprint(portage.settings.get("FETCHCOMMAND"))' | python -)"

	mkdir "$DISTDIR" || die "Unable to create directory: ${DISTDIR}"
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
				eqawarn "No FILE is set, but we found -> as an second argument."
				die "Malformed sources list."
			fi
		fi

		ebegin "Downloading live sources form '${URI}'"
		eval "${FCMD}"
		eend "$?"

	done <<< "$@"
}

#live-fetch_pkg_setup {
#	live-fetch "${SRC_URI}"
#}

live-fetch_src_unpack() {
	live-fetch "${LIVE_URI}"
	unpack "${T}/sources/"*
}

EXPORT_FUNCTIONS src_unpack
