
# So much TODO!
envvar() {
	if [[ -z "$1" ]]
	then
		eerror "envvar(): No argument given."
		return 1
	fi

	printf 'import portage\nprint(portage.settings.get("%s"))' "$1" | python -
}
