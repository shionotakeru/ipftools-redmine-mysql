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


dst=$1; shift
bootstrap_sh=$1; shift
install_sh=$1; shift
mo_files=($1); shift
rpms=("$@")


# get a temporary directory.
function do_cleanup() {
    [ "x$tmpdir" != x -a -d "$tmpdir" ] && /bin/rm -rf "$tmpdir"
}
tmpdir=""
trap do_cleanup 0 1 2 3 15
tmpdir="`mktemp -d /var/tmp/ipftools-build.XXXXXXXX`"


# prepare tarball.
for i in $install_sh "${rpms[@]}"; do
    ln -s `pwd`/"$i" $tmpdir/`basename "$i"`
done


# build substiion parameters.
export CATALOG_DATA="`tar cf - --owner=root ${mo_files[*]} | gzip -9 | base64 -w0`"
export START_AT=$((`wc -l < $bootstrap_sh` + 1))


# build setup script.
(
    perl -pe 's/\@\@([A-Z0-9_]+)\@\@/$ENV{$1}/g' $bootstrap_sh
    (cd $tmpdir ; tar chfv - --owner=root *) | gzip -9
) > $dst
chmod a+x $dst
echo "
Created $dst"
