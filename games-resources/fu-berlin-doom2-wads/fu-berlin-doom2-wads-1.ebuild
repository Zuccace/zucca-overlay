# Copyright 1999-2021
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit check-reqs multiprocessing

DESCRIPTION="A HUGE set of wads for Doom II from fu-berlin ftp site"
HOMEPAGE="ftp://ftp.fu-berlin.de/pc/games/idgames/levels/doom2/"
RESTRICT="mirror"

# cpio created with:
# ncftpls 'ftp://ftp.fu-berlin.de/pc/games/idgames/levels/doom2/*-*' | awk '{print "ftp://ftp.fu-berlin.de/pc/games/idgames/levels/doom2/" $1}' | xargs ncftpls | grep '\.zip$' | tac | awk '{print "url = \"ftp://ftp.fu-berlin.de/pc/games/idgames/levels/doom2/" $0 "\""; sub(/^.*\//,""); print "output = \"" $0 "\"\n"}' | curl --config - && find -type f -iname '*.zip' | cpio -o > fu-berlin-doom2-wads.cpio
MY_PKG="${PN}.cpio"
BASE_URI="http://kahvipannu.com/~zucca/doom"
SRC_URI="${BASE_URI}/${MY_PKG}"

DEPEND=""
BDEPEND="
	app-arch/cpio
	app-arch/unzip
	app-misc/detox
"

if [ "$PV" != '1' ]
then
	deltafile="${PF}.bdelta"
	SRC_URI="${SRC_URI} ${BASE_URI}/${deltafile}"
	BDEPEND="${BDEPEND}
	dev-util/bdelta"
fi

HDEPEND="$BDEPEND"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-raw-install +wad-symlink"

RDEPEND=""

countfile="${T%/}/count"
errorfile="${T%/}/error"
zipdir="${T%/}/zips"
packdir="${S%/}/packs"
waddir="/usr/share/games/doom"

check_errorfile() {
	if [ ! -f "$errorfile" ]
	then
		eend '0'
	else
		eend '1' "$1"
		rm "$errorfile"
	fi
}

# Wad creators have put some really nasty characters into filenames... -_-
rename_count() {
	awk '{if ($0 ~ / -> /) {c++; printf "\r%s renamed          ",c} else print } END { print " " }'
}

safe_rename() {
	ebegin "Renaming files with 'nasty' characters"

	# Detox has problems with -r...
	local clean_list=()
	while [ "$1" ]
	do
			clean_list=("${clean_list[@]}" "$(realpath --no-symlinks "$1")")
			shift
	done

	 {
		detox -v -f <(cat <<-EOF
			sequence default {
				iso8859_1;
				safe;
			};
EOF
		) -r "${clean_list[@]}" || die "detox failed to rename files. Aborting!"
		} | rename_count
	eend '0'
}

percent_counter() {
	awk -v "maxc=${1}" '
		BEGIN {
			lastperc = 0
			}
		{
			c++
			perc = int(c * 100 / maxc)
			if (perc > lastperc) {
				printf "\r%s%%    ",perc
				lastperc = perc
			}
		}
		END {
			printf "\r%s%%    \n","100"
			}
	'
}

wad_symlink() {
	if use wad-symlink
	then
		ebegin "Creating symlinks for wads for better compability"
		symlink_wad() {
			local t="${1#./}"
			ln -s "${waddir}/${t}" "${t//\//-}" || touch "$errorfile"
			echo
		}
		export D waddir errorfile
		export -f symlink_wad

		pushd "${D%/}/${waddir}" &> /dev/null || die
		LC_ALL="C" find . -type f -iname '*.wad' | xargs --max-procs="$jobs" -I {} bash -c 'symlink_wad '"'"'{}'"'"'' | awk '{ c++; printf "\r%s    ",c } END { printf "\r"; system("einfo Total of " c " wads symlinked.")}'
		popd &> /dev/null || die
		check_errorfile 'Errors encountered during wad symlink creation'
	fi
}

pkg_pretend() {
	# Yup.
	CHECKREQS_DISK_BUILD="4G"

	check-reqs_pkg_pretend
}

pkg_setup() {
	#jobs="$(grep -Eo "(--jobs|-j)[ =]?[0-9]+" <<< "$MAKEOPTS" | grep -o '[0-9]*')"
	jobs="$(makeopts_jobs)"
	if [ "$jobs" ] && [ "$jobs" -gt 0 ]
	then
		export jobs
	else
		export jobs=1
	fi

	einfo "Using ${jobs} threads for most of the operations."
}

src_unpack() {

	mkdir "$S" || die "Unable to create directory: $S"

	if [ "$PV" != '1' ]
	then
		ebegin "Applying bdelta to '$MY_PKG'"
		cpio_pkg="${T%/}/${PF}.cpio"
		if bpatch "${DISTDIR%/}/${MY_PKG}" "$cpio_pkg" "${DISTDIR%/}/${deltafile}"
		then
			eend 0
			elog "Created a new, temporary, cpio archive: ${cpio_pkg##*/}"
		else
			eend 1
			die "Could not apply deltapatch '${deltafile}' to '${MY_PKG}'."
		fi
	else
		cpio_pkg="${DISTDIR%/}/${MY_PKG}"
	fi

	mkdir "$zipdir" || die "Unable to create directory: $zipdir"
	pushd "$zipdir" &> /dev/null || die "Unable to enter directory: $zipdir"
		ebegin "Scanning packages"
		cpio --list --file="$cpio_pkg" 2> /dev/null | awk -v "countfile=${countfile}" '{ c++; printf "\r%s    ",c } END { printf "\r"; system("einfo Total of " c " wad packages."); print c > countfile}' && eend 0 || eend 1
		fcount="$(cat "$countfile")"

		ebegin "Extracting individual zips from main cpio"
		{ cpio --extract --verbose --file="${DISTDIR%/}/${MY_PKG}" 2>&1 || die "Unpacking main cpio failed." ;} | percent_counter "$fcount"
		eend '0'

		unpack_zip() {
			wadpackdir="${packdir}/${1%.zip}"
			mkdir -p "$wadpackdir" || die "Unable to create directory: $wadpackdir"
			unzip "$1" -d "${wadpackdir}/" &> /dev/null
			rm -f "$1" &> /dev/null

			# Yo dawg! Some packages have more packages inside them... For now we only go two levels deep.
			find "${wadpackdir}/" -type f \( -iname '*.zip' -or -iname '*.exe' \) -execdir unzip {} \; -and -delete &> /dev/null

			echo
		}

		safe_rename "${zipdir}"

		export packdir
		export -f unpack_zip
		ebegin "Processing all the zip files"
		LC_ALL="C" find -type f \( -iname '*.zip' -or -iname '*.exe' \) -print0 | xargs --null --max-procs="$jobs" -I {} bash -c 'unpack_zip '"'"'{}'"'"'' | percent_counter "$fcount"
		safe_rename "${packdir}"
		echo
		eend '0'
	popd &> /dev/null || die
	unset wadpackdir
}

src_configure() {
	if ! use raw-install
	then
		ebegin "Searching misc files for more wads"
		detect_wad() {
			if file -b "$1" | grep -iq '^doom patch [PI]WAD'
			then
				mv -v "$1"{,.wad} || { eerror "Failed to rename '$1'" && touch "$errorfile"; }
			fi
		}
		export errorfile
		export -f detect_wad
		find "${packdir}" -type f -not -iname '*.wad' -print0 | xargs --null --max-procs="$jobs" -I {} bash -c 'detect_wad '"'"'{}'"'"'' | rename_count
		check_errorfile
	fi
}
src_compile() {
	return 0
}

src_install() {

	if use raw-install
	then
		insdir="/opt/doom2-wads"
		ebegin "Performing RAW install into '${insdir}'"
		insinto "$insdir"
		find "$packdir" -mindepth 1 -maxdepth 1 -type d -exec doins -r {} + || die
		eend '0'

	else
		ebegin "Installing WADs, PADs, DEHs, LMPs and docs"
		dodir "${waddir}"
		DOCDIR="${D%/}/usr/share/doc/${PF}"
		dodir "/usr/share/doc/${PF}"
		pushd "$packdir" &> /dev/null || die "Unable to enter directory: ${packdir}"
			# TODO?: this might be better dealt with rsync.
			find -regextype egrep \
				\( -type f -iregex '.+((\.(txt|nfo|info|diz|me|read|md|a(scii)?doc))|readme)' -exec cp --parents -t "${DOCDIR}/" {} + -exec rm {} + \) \
				-or \
				\( -type f -iregex '.+\.(wad|pad|deh|lmp)' -exec cp --parents -t "${D%/}/${waddir}/" {} + -exec rm {} + \) && eend '0' || die
		popd &> /dev/null || die

		wad_symlink

		ebegin "Symlinking all the doc directories"
		while read ddir
		do
			wadpackdir="${D%/}/${waddir}/${ddir}"
			if [ -d "$wadpackdir" ]
			then
				ln -s "${ROOT%/}/usr/share/doc/${PF}/${ddir}" "${wadpackdir}/docs" &> /dev/null || { ewarn "Doc symlink creation into '${wadpackdir}/docs' failed." && touch "$errorfile"; }
			else
				elog "No usable wads in ${ddir} -package. Removing it from installion..."
				touch "${T%/}/empty_dirs"
				rm -fr "${D%/}/usr/share/doc/${PF}/${ddir}"
			fi
			echo
		done < <(find "$DOCDIR" -maxdepth 1 -mindepth 1 -type d -printf '%P\n') | percent_counter "$fcount"
		check_errorfile 'Errors during doc directory symlinking.'

		[ -f "${T%/}/empty_dirs" ] && elog "Some wad packages were without a proper wad. If you want to investigate what's inside them emerge with USE=raw-install."
	fi
}
