#!/bin/bash

: ${prefs:="${HOME}/.config/unity3d/ASMB/DMCA's Sky/prefs"}

pref_prepare() {
    [ -e "$prefs" ] && return 0
    {
        echo '<unity_prefs version_major="1" version_minor="1">'
        echo '</unity_prefs>'
    } > "$prefs"
}

while [ "$1" ]
do
    case "$1" in
        --help|-h|-?)
            echo -e "--force-opengl\n--lives <num>\n--worlds-visited <num>\n\nor\n--reset"
            exit 0
        ;;
        --reset)
            gawk -i inplace '/<\/?unity_prefs|<pref.* name="__Input/' "$prefs"
            exit "$?"
        ;;
        --lives)
            if grep -qE '^[0-9]+$' <<< "$2"
            then
                pref_prepare
                gawk -v "lives=$2" -i inplace '{
                    if (/<unity_prefs/) {
                        print
                        print "\t<pref name=\"NumLives\" type=\"int\">" lives "</pref>"
                    } else if (/name="NumLives"/) next
                    else print
                }' "$prefs"
                shift
            else
                echo "'$2' is not a number"
                exit 1
            fi
        ;;
        --worlds-visited)
            if grep -qE '^[0-9]+$' <<< "$2"
            then
                pref_prepare
                gawk -v "worlds=$2" -i inplace '{
                    if (/<unity_prefs/) {
                        print
                        print "\t<pref name=\"WorldsVisited\" type=\"int\">" worlds "</pref>"
                    } else if (/name="WorldsVisited"/) next
                    else print
                }' "$prefs"
                shift
            else
                echo "'$2' is not a number"
                exit 1
            fi
        ;;
        --force-opengl)
            extra_args=("${extra_args[@]}" -force-opengl)
        ;;
        --)
            shift; break
        ;;
        *)
            extra_args=("${extra_args[@]}" "$1")
        ;;
    esac
    shift
done

: ${dmcass_bin:="/opt/DMCAs-Sky/DMCAsSky.$(uname -m)"}
run_dir="${dmcass_bin%/*}"

cd "$run_dir" || exit 1
./"${dmcass_bin##*/}" "${extra_args[@]}" "$@"
exit "$?"
