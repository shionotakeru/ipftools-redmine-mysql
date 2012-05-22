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

set -ex


if tty -s; then
    function echo_tty() { echo "$@" >/dev/tty; }
else
    function echo_tty() { echo "$@" >&2; }
fi


function no_rpm() {
    if rpm --quiet -q "$1"; then
	return 1
    else
	return 0
    fi
}


PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH


########################################################################
#
# arguments
#
########################################################################
repos="$1"
sample="$2"



########################################################################
#
#  requires
#
########################################################################
case "`uname -m`" in
    i[0-9]86)   arch=i386 ;;
    x86_64)     arch=x86_64 ;;
esac
requires=(
    httpd.$arch
    mod_dav_svn.$arch
    subversion.$arch
    postgresql84-server.$arch
    perl-DBI.$arch
)


########################################################################
#
# rpms
#
########################################################################
rpms=(
    "git*.rpm perl-Git*.rpm"
    "ipftools-redmine*.rpm"
)


########################################################################
#
# Install requires.
#
########################################################################
for i in "${requires[@]}"; do
    if no_rpm "$i"; then
	name="${i%.$arch}"
	echo_tty -n $"Installing ${name}... "
	yum install -y "$name"
	echo_tty $"done."
    fi
done


########################################################################
#
# Install local rpms
#
########################################################################
for files in "${rpms[@]}"; do
    files=(`echo $files`)
    if rpm -U --test "${files[@]}" >/dev/null 2>&1; then
	name="${files[0]%-*-*.rpm}"
	echo_tty -n $"Installing ${name}... "
	rpm -U "${files[@]}"
	echo_tty $"done."
    fi
done


########################################################################
#
# Run setup script.
#
########################################################################
/opt/ipftools/libexec/setup.sh "$repos" "$sample"
