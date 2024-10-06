# GNUpg eclass
#
# Please don't use.

import_gentoo_keys() {
	ebegin "Importing Gentoo release keys"
	if gpg --import "${ROOT}/usr/share/openpgp-keys/gentoo-release.asc" &> "${T}/gpg_import.log"
	then
		eend 0
		return 0
	else
		eend 1 "Importing the keys failed."
		local l
		while read l
		do
			eerror "$l"
		done < "${T}/gpg_import.log"
		return 1
	fi
}

gpgcat() {
	awk '
		($0 == "-----BEGIN PGP SIGNED MESSAGE-----") {
				getline
				while ((getline) > 0 && substr($1,1,5) != "-----")
					if ($1 != "" && substr($1,1,1) != "#") print
				exit
		}
	' "$@"
}

gpgverify() {
	local s l bfile="${1##*/}"
	ebegin "Verifying file: ${bfile}"
	gpg --verify "$1" 2>&1 | tee "${T}/gpg_verify_${bfile}.log" | fgrep 'Good signature'
	s="$?"
	eend "$s" "Failed to verify '${bfile}'!"
	[[ "$s" -gt 0 ]] && eerror "gpg log: ${T}/gpg_verify_${bfile}.log"
	return "$s"
}

