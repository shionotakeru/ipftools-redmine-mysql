#!/bin/bash
#
#   <Quantitative project management tool.>
#
#   Copyright (C) 2012 IPA, Japan.
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -e


PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH


CATALOG_DATA='@@CATALOG_DATA@@'
START_AT=@@START_AT@@


if tty -s; then
    function isatty() { return 0; }
    function echo_tty() { echo "$@" >/dev/tty; }
else
    function isatty() { return 1; }
    function echo_tty() { echo "$@" >&2; }
fi


########################################################################
#
# reset tty
#
########################################################################
function do_exit() {
    rc="$?"
    stty sane
    exit "$rc"
}
trap do_exit 1 2 3 15


########################################################################
#
# get a temporary directory.
#
########################################################################
function do_cleanup() {
    rc="$?"
    if [ -n "$log" -a -f "$log" ]; then
        echo_tty $"Failed to setup..., see $log"
    fi
    [ "x$tmpdir" != x -a -d "$tmpdir" ] && /bin/rm -rf "$tmpdir"
    exit "$rc"
}
tmpdir=""
trap do_cleanup 0
tmpdir="`mktemp -d /var/tmp/ipftools-build.XXXXXXXX`"


########################################################################
#
# extract catalog data.
#
########################################################################
echo "$CATALOG_DATA" | base64 -id 2>/dev/null | tar xfz - -C $tmpdir 2>/dev/null
TEXTDOMAINDIR=$tmpdir/locale
TEXTDOMAIN=ipftools
export TEXTDOMAINDIR TEXTDOMAIN


########################################################################
#
# options
#
########################################################################
repos=
sample=
install=
if [ $# -gt 0 ]; then
    for i in "$@"; do
        case "$i" in
	    --repos=*)
		i="${i#--repos=}"
		case "$i" in
		    svn|git)
			repos="$i"
			;;
		    *)
			echo_tty $"$0: Ignored --repos=$i"
			;;
		esac
		;;
	    --sample=*)
		i="${i#--sample=}"
		case "$i" in
		    0|1)
			sample="$i"
			;;
		    *)
			echo_tty $"$0: Ignored --sample=$i"
			;;
		esac
		;;
	    --install)
		install=1
		;;
	    -*)
		echo_tty $"$0: Unrecognized option '$i'"
		exit 1
		;;
	    *)
		echo_tty $"$0: Unrecognized argument '$i'"
		exit 1
		;;
        esac
    done
fi


########################################################################
#
# show welcome message.
#
########################################################################
echo_tty $"\
Welcome to the IPF Tools (Redmine) setup
----------------------------------------
"


########################################################################
#
# check user
#
########################################################################
if [ "`id -u`" != 0 ]; then
    echo_tty $"You must be root to install."
    exit 1
fi



########################################################################
#
# choose repos
#
########################################################################
if [ -z "$repos" ]; then
    if isatty; then
	while [ -z "$repos" ]; do
	    read -s -n 1 -p $"Select your repository type.
  s) Subversion
  g) Git
" reply || reply=
	    case "$reply" in
		[sS]) repos=svn ;;
		[gG]) repos=git ;;
	    esac
	done
    else
	repos=svn
    fi
fi


########################################################################
#
# choose loading sample
#
########################################################################
if [ -z "$sample" ]; then
    if isatty; then
	while [ -z "$sample" ]; do
	    read -s -n 1 -p $"Do you need sample project? (y/n) " reply || reply=
	    echo_tty
	    case "$reply" in
		[yY]) sample=1 ;;
		[nN]) sample=0 ;;
	    esac
	done
    else
	sample=1
    fi
fi



########################################################################
#
# confirm
#
########################################################################
if [ -z "$install" ]; then
    if isatty; then
	case "$repos" in
	    svn) label_repos=Subversion ;;
	    git) label_repos=Git ;;
	esac
	case "$sample" in
	    1) label_sample=$"Yes" ;;
	    0) label_sample=$"No" ;;
	esac
	while [ -z "$install" ]; do
	    read -s -t 15 -n 1 -p $"
Are you sure you want to install IPF Tools? (y/n)
  Repository type: $label_repos
  Sample projects: $label_sample
" reply || reply=
	    case "$reply" in
		[yY]) install=1 ;;
		[nN]) exit 0 ;;
	    esac
	done
    else
	echo_tty $"This terminal is not a tty. Use --install option to install."
	exit 0
    fi
fi


########################################################################
#
# prepare logging
#
########################################################################
log="`mktemp /var/tmp/ipftools.log.XXXXXXXX`"


########################################################################
#
# extract
#
########################################################################
echo_tty -n $"Extracting... "
tail -n +$START_AT "$0" | tar xfvz - -C $tmpdir >>$log 2>&1
echo_tty $"done."


########################################################################
#
# start install
#
########################################################################
cd $tmpdir
./install.sh "$repos" "$sample" >>$log 2>&1
[ -d /opt/ipftools ] && mv $log /opt/ipftools/install.log

echo $"\
Setup completed!
Launch at http://localhost/redmine.

View the following documents to get more information.

 * For administrators
   - /opt/ipftools/share/htdocs/Implementation Tools (Management) Help.pdf
   - http://localhost/ipftools/Implementation%20Tools%20(Management)%20Help.pdf
 * For users
   - /opt/ipftools/share/htdocs/Implementation Tools (Operation) Help.pdf
   - http://localhost/ipftools/Implementation%20Tools%20(Operation)%20Help.pdf

Please register at the following URL.
http://www.ipa.go.jp/
"
exit 0
