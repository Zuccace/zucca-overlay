#!/bin/bash
#
# Be extra careful:
# Require:
# - ble.sh not sourced yet
# - bash
# - ... that's not open in some ancient terminal
# - ... interactive shell
# - non-root user
# - - would be better also to parse login.defs and limit to non-system users.

if [[ -z "${BLE_ATTACHED}" && "${BASH##*/}" = 'bash' && "${SHELL##*/}" = 'bash' && "${TERM}" != vt* && $- = *i* ]] && tty -s && [[ "$(whoami)" != 'root' ]]
then
	source /usr/share/blesh/ble.sh
fi
