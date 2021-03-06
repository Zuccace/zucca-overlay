# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gog.eclass
# @MAINTAINER:
# Ilja Sara <ilja.sara@kahvipannu.com>
# @BLURB: Helper for .sh "packages" downloaded from gog.

: ${RESTRICT:="fetch strip bindist"}

inherit multiprocessing desktop

# TODO: Explain these variables
GSD='data/noarch/game/'
FGSD="${WORKDIR%/}/${GSD}"
GDD='data/noarch/docs/'
FGDD="${WORKDIR%/}/${GDD}"
GICON='data/noarch/support/icon.png'

IUSE+=" -vanilla-install"

if [[ "$USE" =~ "vanilla-install" ]]
then
	PROPERTIES="interactive"
fi

S="$WORKDIR"

EXPORT_FUNCTIONS src_unpack pkg_nofetch src_compile src_install

# @FUNCTION: gog_src_unpack
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
			ext="${ext,,}"
			case "$ext" in
				sh)
					zip_archive="${T%/}/gog-${PN}-${PV}.zip"
					# Find the byte offset where the zip file starts:
					((zip_offset=$(grep --byte-offset --only-matching --text "$zip_magic" "${DISTDIR%/}/${src_pkg}" | head -n 1 | grep -Eo '^[0-9]+')+1))
					if [[ "$zip_offset" =~ ^[1-9][0-9]*$ ]]
					then
						tail -c +"$zip_offset" "${DISTDIR%/}/${src_pkg}" > "$zip_archive" || die "Failed extracting zip from '${src_pkg}'"
						if [[ "$UNZIP_LIST" ]]
						then
							unzip "$zip_archive" "${UNZIP_LIST[@]}" || die "Failed unzipping '${zip_archive}'"
						else
							unpack "$zip_archive"
						fi

						rm -f "$zip_archive"
					else
						# We have just a regular shell script?
						einfo "Looks like '$src_pkg' isn't a self extracting zip archive."
						einfo "Copying it as is."
						cp "${DISTDIR%/}/${src_pkg}" "${WORKDIR%/}/"
					fi
				;;
				txt|nfo|info|diz|md|log|*doc|*me|*log|pdf|ps|epub)
					# Copy any extra documentation into $T
					src_docdir="${T%/}/src_docs"
					mkdir -p "$src_docdir" 2> /dev/null || die "Unable to create directory: ${src_docdir}"
					cp "${DISTDIR%/}/${src_pkg}" "$src_docdir"/
				;;
				mp*|mov|mkv|jpg|jpeg|png|gif)
					einfo "No need to unpack '$src_pkg'."
				;;
				*)
					nonfatal unpack "$src_pkg"
				;;
			esac
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

# @FUNCTION: goginto
# @USAGE: goginto [subdir]
# @DESCRIPTION:
# Runs required *into functions.
# if subdir is specified then sets install location to
# /opt/gog/<subdir>.
# Otherwise it's /opt/gog/${PN}
# Note that bininto is _not_ ran by this script.
# You're expected to install binaries with doexe
# and then place symlink(s) into /usr/bin that point to
# related binaries, or alternatively create a shell script
# inside /usr/bin which then runs the binary.
goginto() {
	GOGINSTALLDIR="/opt/gog/${subdir:="${1:-"${MY_PN:-"$PN"}"}"}"

	einfo "Installing into ${GOGINSTALLDIR}"
	local into
	for into in exe ins
	do
		"${into}into" "$GOGINSTALLDIR"
	done
}

# @FUNCTION: gog_src_install
# @USAGE: reaplaces default function
# @DESCRIPTION:
# Tries to identify the executable files in the root directory.
# If executables are found then doexe them into a directory under /opt.
# Same for the found docs (but excluding some obvious ones).
# Then remove the said files as the rest gets treated with doins -r *.
gog_src_install() {

	local name="${MY_PN:-"$PN"}"
	local mainbin
	goginto "$name"

	if [[ -z "${GOGBINS}" ]]
	then
		# No binaries specified.
		ewarn "This ebuild has GOGBINS unset."
		ewarn "Will try to locate binaries automatically..."
		# This is rather hacky...
		ebegin "Locating binaries"
		local exe
		local baseexe
		local binsym
		local estatus=1
		pushd "${FGSD%/}" &> /dev/null || die "Unable to switch to directory: ${FGSD%/}"

			while read -d '' exe
			do
				doexe "$exe"
				baseexe="$(basename ${exe})"
				baseexe="${baseexe,,}"
				
				if [[ "${baseexe}" = "${PN,,}"* || "${baseexe}" = "${name,,}"* ]]
				then
					binsym="/usr/bin/${baseexe}"
				else
					binsym="/usr/bin/${name}-${baseexe}"
				fi
				dosym "${GOGINSTALLDIR%/}/${exe}" "$binsym"
				rm "$exe"
				einfo "Found '$baseexe'. Installed as symlink: ${binsym}"
				
				estatus=0
				
			done < <(find . ./bin /exe -maxdepth 1 -type f -print0 2> /dev/null | passbinary)
			
		popd &> /dev/null
		
		eend "$estatus" 'No suitable binaries found.'

	elif [[ "$(declare -p GOGBINS)" =~ "^declare -a" ]]
	then
		# GOGBINS is an array.
		doexe "${GOGBINS[@]}"
		rm "${GOGBINS[@]}"
		mainbin="/usr/bin/$PN"
		dosym "${GOGINSTALLDIR%/}/$(basename "${GOGBINS[0]}")" "$mainbin"

		local numbins n basesym
		((numbins=${#GOGBINS[@]}-1))
		for n in $(seq '1' "$numbins")
		do
			basesym="$(basename "${GOGBINS[$n]}")"
			dosym "${GOGINSTALLDIR%/}/${basesym}" "/usr/bin/${basesym}"
		done	
	else
		# We have space seperated list of binaries...
		local e
		local b="${GOGBINS%% *}"
		doexe "$b"
		rm "$b"
		GOGBINS="${GOGBINS#* }"
		mainbin="/usr/bin/$PN"
		dosym "${GOGINSTALLDIR%/}/$(basename "${b}")" "$mainbin"

		if [[ "${#GOGBINS}" -gt 0 ]]
		then
			while read -d ' ' e
			do
				doexe "$e"
				rm "$e"
			done <<< "$GOGBINS"
		fi
	fi

	# Desktop meny entry creation.
	: ${GOGICON:="${WORKDIR%/}/data/noarch/support/icon.png"}
	local iconext="${GOGICON##*.}"
	nonfatal newicon "$GOGICON" "${PN}.${iconext}"

	if [[ "$mainbin" ]]
	then
		# We have a main binary.
		make_desktop_entry "$mainbin" "$name" "$PN"
	elif [[ -f "${ED%/}/usr/bin/${PN}" ]]
	then
		make_desktop_entry "/usr/bin/${PN}" "$name" "$PN"
	elif [[ -f "${ED%/}/usr/bin/${name}" ]]
	then
		make_desktop_entry "/usr/bin/${name}" "$name" "$PN"
	else
		ewarn "Couldn't locate a possible main executable for ${name}."
		ewarn "No desktop menu entry will be installed."
	fi
	
	# Install documentation.
	if [[ "$(declare -p DOCS 2> /dev/null)" =~ "^declare -a" ]]
	then
		# DOCS is an array
		dodoc "${DOCS[@]}"
		rm "${DOCS[@]}"
	elif [[ "$DOCS" ]]
	then
		local d
		while read -d ' ' d
		do
			dodoc "$d"
			rm "$d"
		done <<< "$DOCS"
	else
		# Going brute...
		# Delete install and licensing documents.
		find "${FGDD%/}" -type f \( -iname '*install*' -o -iname '*licence*' -o -iname '*license*' \) -delete
		notempty "${FGDD%/}"  && dodoc -r "${FGDD%/}"/*

		local tdocs="${T%/}/moved_docs"
		mkdir -p "$tdocs"
		find "${FGSD%/}" -type f -regextype egrep -iregex '.+((\.(txt|nfo|info|diz|me|read|md|log|(a(scii)?)?doc))|readme|changelog|log|pdf|ps|epub)' -exec cp -t "$tdocs" {} + -delete
		notempty "$tdocs" && dodoc "$tdocs"/*
	fi
	
	# Do normal install to what's left.
	# This is the reason we rm'd files earlier.
	doins -r "${FGSD%/}"/*
	# Also check if any docs were downloaded seperatedly from main game archive.
	[[ "$src_docdir" ]] && dodoc -r "$src_docdir"/*
}


# @FUNCTION: gog_pkg_nofetch
# @USAGE: reaplaces default function
# @DESCRIPTION:
# Instructs user maybe a little better?
gog_pkg_nofetch() {
	einfo 'You need to buy the game from gog.com. Then save the *.sh file to your distdir.'
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

# @FUNCTION: gog_src_compile
# @USAGE: gog_src_compile
# @DESCRIPTION:
# Avoid running anything in compile phase.
# This is for gog games after all. ;)
# There shouldn't be anything to compile.
# By using this default we avoid any
# unexpected commands to be run on src_compile()
gog_src_compile() {
	einfo "No compiling needed."
}

# In NUL separated list of files.
# Out NUL separated list of executables and scripts.
# Uses 'file' to roughly identify the files.
passbinary() {
	xargs --max-args 1 --max-procs="$(makeopts_jobs 2)" --null --no-run-if-empty file --print0 --print0 \
		| awk '
			BEGIN {
				FS=","
				ORS="\0"
				RS=ORS
			}
			{
				file=$1
				getline
				if ($1 ~ /(executable|script)$/) print file
			}
		'
}

notempty() {
	[[ "$@" ]] || die "notempty() Requires at least one directory as an argument"
	[[ ! -n "$(find "$@" -prune -empty -type d 2> /dev/null)" ]]
}
