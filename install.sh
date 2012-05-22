#!/bin/sh

mkdir tmp

yum -y install httpd

if [ -f /etc/httpd/conf/httpd.conf ];
then
    cat /etc/httpd/conf/httpd.conf | \
        sed -e "/mod_proxy.so/s/#LoadModule/LoadModule/" | \
        sed -e "/mod_proxy_ajp.so/s/^#LoadModule/LoadModule/" | \
        sed -e "/AddDefaultCharset/s/'UTF-8'/off/"
        > ./tmp/httpd.conf
    cp -f ./tmp/httpd.conf /etc/httpd/conf/httpd.conf
fi

if [ ! -f /etc/httpd/conf.d/proxy_ajp.conf ];
then
    sed -e "s/%SERVERNAME%/$SEVERNAME/g" ./tmp/proxy_ajp.conf \
        > /etc/httpd/conf.d/proxy_ajp.conf
fi

if [ -z `echo $JAVA_HOME` ];
then
    mkdir /usr/java
    cp -p jre-6u26-linux-i586-rpm.bin
    pushd /usr/java
    ./jre-6u26-linux-i586-rpm.bin
    rm ./jre-6u26-linux-i586-rpm.bin
    popd
    echo "export JAVA_HOME=/usr/java/jre1.6.0_26" >> /etc/profile
    echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
fi

pushd ./tmp
wget http://www.meisei-u.ac.jp/mirror/apache/dist/tomcat/tomcat-6/v6.0.32/bin/apache-tomcat-6.0.32.tar.gz
tar -xzf apache-tomcat-6.0.32.tar.gz
mv -f apache-tomcat-6.0.32 /opt/tomcat6
popd

mysql -u root -pPassword < installer/init.sql
mysql -u root -pPassword < installer/setup.sql

pushd ./tmp
unzip IPAexfont00103.zip
cp IPAexfont00103/ipaexg.ttf /usr/share/fonts/ja/TrueType
mkfontdir
mkfontscale
fc-cache -fv
popd

cp -rf ./externals/birt-viewer /opt/tomcat6/webapps/
sed -e "s/%SERVERNAME%/$SERVERNAME/" ./externals/birt-viewer/report/library/IPFCommon.rptlibrary > /opt/tomcat6/webapps/birt-viewer/report/library/IPFCommon.rptlibrary

service httpd start
/opt/tomcat6/bin/startup.sh

mysql -u root -pPassword < ./externals/IPFDB_pm_data.sql

wget http://sourceforge.net/projects/pentaho/files/Data%20Integration/4.3.0-stable/pdi-ce-4.3.0-stable.tar.gz/download
tar -zxf pdi-ce-4.3.0-stable.tar.gz
mkdir -p /opt/ipftools/pentaho
mv data-integration /opt/ipftools/pentaho

cp -rf ./external/batch /opt/ipftools/
sed -e "s/%JAVA%/$JAVA_HOME/" ./external/batch/set-batch-env.sh \
    > /opt/ipftools/batch/set-batch-env.sh
sed -e "s/%SERVAERNAME%/$SERVERNAME/" ./external/batch/.kettle/kettle.properties \
    > /opt/ipftools/batch/.kettle/kettle.properties
>
cp -rf ./external/script /opt/ipftools/

pushd $REDMINE_HOME
RM_HOST=`awk -F : '/production/{ while (getline); do; if ( $1 = "host" ) { print $2; break; }; done;' ./config/database.yml`
RM_PORT=`awk -F : '/production/{ while (getline); do; if ( $1 = "port" ) { print $2; break; }; done;' ./config/database.yml`
RM_DBNM=`awk -F : '/production/{ while (getline); do; if ( $1 = "database" ) { print $2; break; }; done;' ./config/database.yml`
RM_USER=`awk -F : '/production/{ while (getline); do; if ( $1 = "username" ) { print $2; break; }; done;' ./config/database.yml`
RM_PSWD=`awk -F : '/production/{ while (getline); do; if ( $1 = "password" ) { print $2; break; }; done;' ./config/database.yml`

RM_FILEPATH=`awk -F : '/^  attachments_storage_path/{ print $2; }' ./config/configuration.yml`
if [ -z "$RM_FILEPATH" ];
then
    RM_FILEPATH=$REDMINE_HOME/files
fi

for CONVFILE in backup_settings.yml ipf_data_insert_settings.yml
do
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/$CONVFILE > $IPFTOOLS_HOME/script/*/config/$CONVFILE
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/$CONVFILE > $IPFTOOLS_HOME/script/*/config/$CONVFILE
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/$CONVFILE > $IPFTOOLS_HOME/script/*/config/$CONVFILE
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/$CONVFILE > $IPFTOOLS_HOME/script/*/config/$CONVFILE
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/$CONVFILE > $IPFTOOLS_HOME/script/*/config/$CONVFILE
done

    sed -e "s/%RM_FILEPATH%/$RM_FILEPATH/" ./script/*/config/backup_settings.yml > $IPFTOOLS_HOME/script/*/config/backup_settings.yml
    sed -e "s/%RM_HOST%/$RM_HOST/" ./script/*/config/restore_settings.yml > $IPFTOOLS_HOME/script/*/config/restore_settings.yml

cp -rf ./externarl/plugins/* $REDMINE_HOME/vendor/plugins/
RM_OWNER=`ls -l $REDMINE_HOME/vendor/plugins | awk '{ print $2 ':' $3}'`

pushd $REDMINE_HOME
rake db:migrate_plugins RAILS=production

mysql -u root -pPAssword redmine < ./tmp/redmine_init.sql

