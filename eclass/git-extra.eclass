# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-extra.eclass
# @MAINTAINER:
# Ilja Sara <ilja.sara@kahvipannu.com>
# @BLURB: extra functionality to git-r3

#EGIT_CLONE_TYPE='mirror'

inherit git-r3

EXPORT_FUNCTIONS src_prepare

# @FUNCTION: git_since_commit
# @USAGE: git_since_commit
# @DESCRIPTION:
# Prints time since commit in human readable form.
git_since_commit() {
	gawk '
		BEGIN {
			lccmd="git --no-pager log -1 --date=unix --format=\"%cd\""
			lccmd | getline commitdate
			close(lccmd)

			since = systime() - commitdate

			seconds = since % 60
			since -= seconds
			since /= 60
			minutes = since % 60
			since -= minutes
			since /= 60
			hours = since % 24
			since -= hours
			days = since/24

			print days "d " hours "h " minutes "m"

		}
	'
}

# @FUNCTION: git_nfo
# @USAGE: git_nfo [install [filebasename]]
# @DESCRIPTION:
# Prints information about currently fetched git repository.
# Can also install the information when given install as the first argument.
# Then the third argument can be use to change the name of the file.
# The installed file gets installed via dodoc or newdoc function.
git_nfo() {
	local git_nfo_file="${T%/}/git_version.nfo"
	local TAG CNUM

	pushd "${S}" > /dev/null || die "git_nfo(): Unable to enter directory '${S}' (\$S)."
	
	git config --add safe.directory ./
	
        [[ ! -f "$git_nfo_file" ]] && {
                TAG="$(git tag --sort=-creatordate | head -n 1)"
                echo "tag: ${TAG:-"[notag]"}"
                CNUM="$(git rev-list --count ${TAG:+${TAG}..}HEAD)"
                echo "commit number (since tag): ${CNUM:-"N/A"}"
                echo "commit: $(git rev-parse HEAD)"
		echo "time since commit: $(git_since_commit)"
                echo "PF: ${PN}-${TAG:-tag}${CNUM:+"_p${CNUM}"}"
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
	popd > /dev/null
}

# @FUNCTION: git-extra_pkg_postinst
# @USAGE: git-extra_pkg_postinst
# @DESCRIPTION:
# Prints out git information after installation.
git-extra_src_prepare() {

	eapply_user
	
	local L
	pushd "$S" &> /dev/null
	git_nfo | while read L
	do
		elog "$L"
	done
	popd &> /dev/null
}
