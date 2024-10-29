
EAPI=8
inherit acct-user
ACCT_USER_ID=16000
ACCT_USER_ENFORCE_ID='yes'
ACCT_USER_GROUPS=( player games audio video input )
ACCT_USER_HOME='/var/player/home'
ACCT_USER_HOME_PERMS='0770'
ACCT_USER_SHELL='/bin/bash'

ACCT_USER_COMMENT="A general user account for gaming."

acct-user_add_deps
