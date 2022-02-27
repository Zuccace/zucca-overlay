# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-extra.eclass
# @MAINTAINER:
# Ilja Sara <ilja.sara@kahvipannu.com>
# @BLURB: extra functionality to git-r3

inherit git-r3

EXPORT_FUNCTIONS pkg_postinst

# @FUNCTION: git_nfo
# @USAGE: git_nfo [install [filebasename]]
# @DESCRIPTION:
# Returns information about currently fetched git repository
# Can also install the information when given install as the first argument.
# Then the third argument can be use to change the name of the file.
# The installed file gets installed via dodoc or newdoc function.
git_nfo() {
	local git_nfo_file="${T%/}/git_version.nfo"
	local TAG CNUM

        [[ ! -f "$git_nfo_file" ]] && {
                TAG="$(git tag --list --sort=-version:refname | head -n 1)"
                echo "tag: ${TAG:-"[notag]"}"
                CNUM="$(git rev-list --count ${TAG:+${TAG}..}HEAD)"
                echo "commit number (since tag): ${CNUM}"
                echo "commit: $(git rev-parse HEAD)"
                echo "PF: ${PN}-${TAG}_p${CNUM}"
        } > "$git_nfo_file"

	case "$1" in
		install)
			if [[ "$2" ]]
			then
				newdoc "$git_nfo_file" "$2"
			else
        			dodoc "$git_nfo_file"
			fi
		;;
		*)
			cat "$git_nfo_file"
		;;
	esac
}

# @FUNCTION: git-extra_pkg_postinst
# @USAGE: git-extra_pkg_postinst
# @DESCRIPTION:
# Prints out git information after installation.
git-extra_pkg_postinst() {
	
	local L
	pushd "$S" &> /dev/null
	git_nfo | while read L
	do
		einfo "$L"
	done
	popd &> /dev/null
}
