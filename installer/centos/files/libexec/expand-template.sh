#!/bin/sh
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

# arguments
src="$1"
case "$src" in
*.in)
    dst=${src%.in}
    ;;
*)
    dst=$src
    ;;
esac


# prepare template file.
temp=
trap '/bin/rm -f $temp' EXIT
temp=`mktemp`


# execute expanding
perl -pe 's/\@\@([A-Z0-9_]+)\@\@/$ENV{$1}/g' $src >$temp


# replace destination file.
[ $src != $dst -a -f $dst ] && /bin/cp -f $dst ${dst}.orig || /bin/cp -f $src $dst
/bin/cp -f $temp $dst
