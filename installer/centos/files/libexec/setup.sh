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


function service_not_running() {
    if service "$1" status >/dev/null 2>&1; then
	return 1
    else
	return 0
    fi
}


prefix=/opt/ipftools
export PATH=${prefix}/bin:/sbin:/usr/sbin:/bin:/usr/bin


########################################################################
#
# arguments
#
########################################################################
repos="$1"
sample="$2"


########################################################################
#
# save configurations.
#
########################################################################
echo "IPFTOOLS_SCM=$repos" >> $prefix/var/config
echo "IPFTOOLS_IPFDB_PASSWORD=ipf" >> $prefix/var/config
echo "IPFTOOLS_RMDB_PASSWORD=redmine" >> $prefix/var/config


########################################################################
#
# import configurations.
#
########################################################################
. $prefix/var/config


########################################################################
#
# define related configuratios.
#
########################################################################
export IPFTOOLS_SCM
export IPFTOOLS_IPFDB_PASSWORD
export IPFTOOLS_RMDB_PASSWORD
export IPFTOOLS_ROOT=$prefix
export IPFTOOLS_DATA_DIR=$prefix/var
export IPFTOOLS_PGSQL_BIN=/usr/bin
export IPFTOOLS_GIT_BIN=/usr/bin
export IPFTOOLS_SVN_BIN=/usr/bin
export IPFTOOLS_BATCH_EXT=.sh
export IPFTOOLS_SCM_REPOSITORY_DIR=${IPFTOOLS_DATA_DIR}/${IPFTOOLS_SCM}

export RAILS_ENV=production
export REDMINE_LANG=ja


########################################################################
#
# SELinux
#
########################################################################
echo_tty -n $"Checking SELinux... "
check_selinux=0
[ ! -a /selinux/enforce -o "`cat /selinux/enforce`" = 0 ] \
    || check_selinux=1
[ ! -a /etc/selinux/config ] \
    || grep -q '^ *SELINUX *= *disabled *' /etc/selinux/config >/dev/null 2>&1 \
    || check_selinux=1
if [ $check_selinux != 0 ]; then
    echo_tty -n $"Disabling SELinux... "
    echo -n $"Disabling SELinux... "
    test -a /selinux/enforce \
        && echo -n 0 >/selinux/enforce
    test -a /etc/selinux/config \
        && sed -i -e 's/^ *SELINUX *= *[a-z]*.*/SELINUX=disabled/' /etc/selinux/config
fi
echo_tty $"done."


########################################################################
#
# expand templates.
#
########################################################################
pushd $prefix
    for i in `cat libexec/templates.lst`; do
	$prefix/libexec/expand-template.sh "$i"
    done
popd



########################################################################
#
# pgsql - initdb
#
########################################################################
if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
    echo_tty -n $"Initializing PostgreSQL database... "
    /sbin/service postgresql initdb
    echo_tty $"done."
fi


########################################################################
#
# pgsql - pg_hba.conf
#
########################################################################
if grep -q -P "host\s+ipf\s+ipf\s+127.0.0.1/32\s+md5" /var/lib/pgsql/data/pg_hba.conf; then
    :
else
    echo_tty -n $"Adding ipf entry to /var/lib/pgsql/data/pg_hba.conf... "
    for name in redmine ipf; do
	sed -i -e "1 i host ${name} ${name} 127.0.0.1/32 md5" /var/lib/pgsql/data/pg_hba.conf
    done
    service postgresql stop >/dev/null 2>&1 || :
    echo_tty $"done."
fi


########################################################################
#
# pgsql - start
#
########################################################################
if service_not_running postgresql; then
    echo_tty -n $"Starting PostgreSQL... "
    service postgresql start >/dev/null 2>&1
    
    for i in `seq 1 15`; do
        su - postgres -c "/usr/bin/psql -l" >/dev/null 2>&1 && break
        sleep 1
    done
    su - postgres -c "/usr/bin/psql -l" >/dev/null 2>&1
    echo_tty $"done."
fi


########################################################################
#
# ipfdb
#
########################################################################
if su - postgres -c "/usr/bin/psql -l 2>/dev/null | grep -q -E '^ +ipf '"; then
    :
else
    echo_tty -n $"Creating ipf database... "
    su - postgres -c "/usr/bin/psql" <<_EOF_
CREATE USER ipf WITH PASSWORD '${IPFTOOLS_IPFDB_PASSWORD}' SUPERUSER;
CREATE DATABASE ipf TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C' OWNER ipf;
CREATE USER redmine WITH PASSWORD '${IPFTOOLS_RMDB_PASSWORD}' SUPERUSER;
CREATE DATABASE redmine TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C' OWNER redmine;
_EOF_
    PGPASSWORD="$IPFTOOLS_IPFDB_PASSWORD" psql -E -h 127.0.0.1 -d ipf -U ipf -f ${prefix}/libexec/IPFDB_ipf.sql
    PGPASSWORD="$IPFTOOLS_IPFDB_PASSWORD" psql -E -h 127.0.0.1 -d ipf -U ipf -f ${prefix}/libexec/IPFDB_pm_data.sql
    echo_tty $"done."
fi


########################################################################
#
# redmine
#
########################################################################
echo_tty -n $"Initializing Redmine... "
pushd ${prefix}/redmine
    sudo -u apache -E ${prefix}/bin/rake generate_session_store
    sudo -u apache -E ${prefix}/bin/rake db:migrate
    sudo -u apache -E ${prefix}/bin/rake redmine:load_default_data
    sudo -u apache -E ${prefix}/bin/rake db:migrate_plugins

    sudo -u apache -E ${prefix}/bin/ruby script/runner ${prefix}/libexec/setup-redmine-ipf-plugins.rb
popd
echo_tty $"done."


########################################################################
#
# ipf - load master and sample data
#
########################################################################
pushd ${prefix}/script/ipf_data_insert
    echo_tty -n $"Loading master data... "
    sudo -u apache ${prefix}/bin/ruby ipf_master_data.rb
    sudo -u apache ${prefix}/bin/ruby ipf_master_project.rb
    echo_tty $"done."

    if [ "$sample" == "1" ]; then
	echo_tty -n $"Loading sample data... "
	sudo -u apache ${prefix}/bin/ruby ipf_sample_project.rb
	echo_tty $"done."
    fi
popd


########################################################################
#
# httpd - start
#
########################################################################
if service_not_running httpd; then
    echo_tty -n $"Starting httpd... "
    service httpd start >/dev/null 2>&1
    echo_tty $"done."
fi


########################################################################
#
# chkconfig
#
########################################################################
for name in postgresql httpd ipftools-tomcat; do
    echo_tty -n $"Enabling ${name} to automatically start... "
    /sbin/chkconfig $name on >/dev/null 2>&1 || :
    echo_tty $"done."
done
